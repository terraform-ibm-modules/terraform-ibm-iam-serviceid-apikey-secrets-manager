variable "prefix" {
  description = "Prefix for name of all resource created by this example"
  type        = string
  default     = "test-iam-serviceid-apikey"
}

variable "ibmcloud_api_key" {
  type        = string
  description = "APIkey that's associated with the account to use, set via environment variable TF_VAR_ibmcloud_api_key or .tfvars file."
  sensitive   = true
}

variable "sm_iam_secret_name" {
  type        = string
  description = "Name of SM IAM secret (dynamic ServiceID API Key) to be created"
  default     = "sm-iam-secret-puller" #tfsec:ignore:general-secrets-no-plaintext-exposure
}

variable "region" {
  type        = string
  description = "Region where resources will be created"
  default     = "au-syd"
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example, if unset a new resource group will be created"
  default     = null
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
}

variable "existing_sm_instance_crn" {
  type        = string
  description = "Existing Secrets Manager CRN. If not provided a new instance will be provisioned"
  default     = null
}

variable "skip_iam_authorization_policy" {
  type        = bool
  description = "Whether to skip the creation of the IAM authorization policies required to enable the IAM credentials engine. If set to false, policies will be created that grants the Secrets Manager instance 'Operator' access to the IAM identity service, and 'Groups Service Member Manage' access to the IAM groups service."
  default     = false
}

variable "account_id" {
  description = "The ID of the target account in which the IAM credentials are created. Use this field only if the target account is not the same as the account of the Secrets Manager instance."
  type        = string
  default     = null


  validation {
    condition     = (var.account_id == null || (var.account_id != null && var.ibmcloud_target_account_api_key != null))
    error_message = "The variable ibmcloud_target_account_api_key must be set when account_id is provided."
  }
}

variable "ibmcloud_target_account_api_key" {
  type        = string
  description = "IBM Cloud API key for the target account. This key is required for cross-account setups to manage Secrets Manager and IAM resources. If not provided, the value of ibmcloud_api_key is used. Leave this unset when the service ID and Secrets Manager instance are in the same account."
  sensitive   = true
  default     = null
}
