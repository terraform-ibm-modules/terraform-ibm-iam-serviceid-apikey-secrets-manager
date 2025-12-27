##############################################################################
# Locals
##############################################################################

locals {
  parsed_existing_sm_instance_crn = var.existing_sm_instance_crn != null ? split(":", var.existing_sm_instance_crn) : []
  sm_region                       = length(local.parsed_existing_sm_instance_crn) > 0 ? local.parsed_existing_sm_instance_crn[5] : var.region
}

##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.4.7"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-rg" : null
  existing_resource_group_name = var.resource_group
}

########################################
## Secrets-Manager and IAM configuration
########################################

## IAM user policy, SM instance, Service ID for IAM engine, IAM service ID policies, associated Service ID API key stored in a secret object in account level secret-group and IAM engine configuration

module "secrets_manager" {
  source                        = "terraform-ibm-modules/secrets-manager/ibm"
  version                       = "2.12.12"
  existing_sm_instance_crn      = var.existing_sm_instance_crn
  skip_iam_authorization_policy = var.skip_iam_authorization_policy
  resource_group_id             = module.resource_group.resource_group_id
  region                        = local.sm_region
  secrets_manager_name          = "${var.prefix}-secrets-manager"
  sm_service_plan               = "trial"
  allowed_network               = "private-only"
  endpoint_type                 = "private"
  sm_tags                       = var.resource_tags
}

# Additional Secrets-Manager Secret-Group for SERVICE level secrets
module "secrets_manager_group_acct" {
  source               = "terraform-ibm-modules/secrets-manager-secret-group/ibm"
  version              = "1.3.34"
  region               = local.sm_region
  secrets_manager_guid = module.secrets_manager.secrets_manager_guid
  #tfsec:ignore:general-secrets-no-plaintext-exposure
  secret_group_name        = "${var.prefix}-account-secret-group"           #checkov:skip=CKV_SECRET_6: does not require high entropy string as is static value
  secret_group_description = "Secret-Group for storing account credentials" #tfsec:ignore:general-secrets-no-plaintext-exposure
  endpoint_type            = "private"
}

module "secrets_manager_group_service" {
  source               = "terraform-ibm-modules/secrets-manager-secret-group/ibm"
  version              = "1.3.34"
  region               = local.sm_region
  secrets_manager_guid = module.secrets_manager.secrets_manager_guid
  #tfsec:ignore:general-secrets-no-plaintext-exposure
  secret_group_name        = "${var.prefix}-svc-secret-group"
  secret_group_description = "service secret group" #tfsec:ignore:general-secrets-no-plaintext-exposure
  endpoint_type            = "private"
}

########################
## ServiceIDs and Policy
##
## Naming convention: https://ibm.ent.box.com/notes/817026596377
## sid:version:name:stype:service-name:resource-type:resource
#######################

resource "ibm_iam_service_id" "secret_puller" {
  name        = "sid:0.0.1:${var.prefix}-secret-puller:automated:simple-service:secret-manager:"
  description = "ServiceID that can pull secrets from Secret Manager"
}

resource "ibm_iam_service_policy" "secret_puller_policy" {
  iam_id = ibm_iam_service_id.secret_puller.iam_id
  roles  = ["Viewer", "SecretsReader"]

  resources {
    service              = "secrets-manager"
    resource_instance_id = module.secrets_manager.secrets_manager_guid
    resource_type        = "secret-group"
    resource             = module.secrets_manager_group_acct.secret_group_id
  }
}

##################################################################
## Dynamic Service ID API Key / SM secret
##################################################################

module "dynamic_serviceid_apikey1" {
  source = "../.."
  region = local.sm_region
  #tfsec:ignore:general-secrets-no-plaintext-exposure
  sm_iam_secret_name        = "${var.prefix}-${var.sm_iam_secret_name}"
  sm_iam_secret_description = "Example of dynamic IAM secret / apikey" #tfsec:ignore:general-secrets-no-plaintext-exposure
  serviceid_id              = ibm_iam_service_id.secret_puller.id
  secrets_manager_guid      = module.secrets_manager.secrets_manager_guid
  secret_group_id           = module.secrets_manager_group_service.secret_group_id
  service_endpoints         = "private"
}
