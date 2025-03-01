##############################################################################
# Locals
##############################################################################

locals {
  validate_sm_region_cnd = var.existing_sm_instance_crn != null && var.existing_sm_instance_region == null
  validate_sm_region_msg = "existing_sm_instance_region must also be set when value given for existing_sm_instance_crn."
  # tflint-ignore: terraform_unused_declarations
  validate_sm_region_chk = regex(
    "^${local.validate_sm_region_msg}$",
    (!local.validate_sm_region_cnd
      ? local.validate_sm_region_msg
  : ""))

  sm_region  = var.existing_sm_instance_region == null ? var.region : var.existing_sm_instance_region
  sm_acct_id = var.existing_sm_instance_crn == null ? module.iam_secrets_engine[0].acct_secret_group_id : module.secrets_manager_group_acct[0].secret_group_id
}

##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.6"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-rg" : null
  existing_resource_group_name = var.resource_group
}

########################################
## Secrets-Manager and IAM configuration
########################################

## IAM user policy, SM instance, Service ID for IAM engine, IAM service ID policies, associated Service ID API key stored in a secret object in account level secret-group and IAM engine configuration

module "secrets_manager" {
  source                   = "terraform-ibm-modules/secrets-manager/ibm"
  version                  = "1.24.3"
  existing_sm_instance_crn = var.existing_sm_instance_crn
  resource_group_id        = module.resource_group.resource_group_id
  region                   = local.sm_region
  secrets_manager_name     = "${var.prefix}-secrets-manager"
  sm_service_plan          = "trial"
  allowed_network          = "private-only"
  endpoint_type            = "private"
  sm_tags                  = var.resource_tags
}

# Configure instance with IAM engine
module "iam_secrets_engine" {
  count                = var.existing_sm_instance_crn == null ? 1 : 0
  source               = "terraform-ibm-modules/secrets-manager-iam-engine/ibm"
  version              = "1.2.8"
  region               = local.sm_region
  secrets_manager_guid = module.secrets_manager.secrets_manager_guid
  iam_engine_name      = "generated_iam_engine"
  endpoint_type        = "private"
}

# Additional Secrets-Manager Secret-Group for SERVICE level secrets
module "secrets_manager_group_acct" {
  count                = var.existing_sm_instance_crn == null ? 0 : 1
  source               = "terraform-ibm-modules/secrets-manager-secret-group/ibm"
  version              = "1.2.2"
  region               = local.sm_region
  secrets_manager_guid = module.secrets_manager.secrets_manager_guid
  #tfsec:ignore:general-secrets-no-plaintext-exposure
  secret_group_name        = "${var.prefix}-account-secret-group"           #checkov:skip=CKV_SECRET_6: does not require high entropy string as is static value
  secret_group_description = "Secret-Group for storing account credentials" #tfsec:ignore:general-secrets-no-plaintext-exposure
  endpoint_type            = "private"
}

module "secrets_manager_group_service" {
  source               = "terraform-ibm-modules/secrets-manager-secret-group/ibm"
  version              = "1.2.2"
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
  iam_service_id = ibm_iam_service_id.secret_puller.id
  roles          = ["Viewer", "SecretsReader"]

  resources {
    service              = "secrets-manager"
    resource_instance_id = module.secrets_manager.secrets_manager_guid
    resource_type        = "secret-group"
    resource             = local.sm_acct_id
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
