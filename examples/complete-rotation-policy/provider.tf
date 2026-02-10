provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}

provider "ibm" {
  alias            = "target-account"
  ibmcloud_api_key = var.ibmcloud_target_account_api_key != null ? var.ibmcloud_target_account_api_key : var.ibmcloud_api_key
  region           = local.sm_region
}
