##############################################################################
# Input Variables
##############################################################################

variable "sm_iam_secret_name" {
  type        = string
  description = "Name of SM IAM secret (dynamic ServiceID API Key) to be created"
}

variable "sm_iam_secret_description" {
  type        = string
  description = "Description of SM IAM secret (dynamic ServiceID API Key) to be created"
}

variable "serviceid_id" {
  type        = string
  description = "ID of ServiceID the dynamic secret/API key authenticates"
}

variable "secrets_manager_guid" {
  type        = string
  description = "Instance ID of Secrets Manager instance in where secret is stored"
}

variable "secret_group_id" {
  type        = string
  description = "Secret Group ID of secret where IAM Secret will be added to, leave default (null) to add in default secret-group"
  default     = null #tfsec:ignore:GEN001
}

variable "sm_iam_secret_ttl" {
  type        = string
  description = "Specify validity / lease duration of ServiceID API key. Accepted values and formats are: SECONDS, Xm or Xh (where X is the number of minutes or hours appended to m or h respectively)"
  default     = "7776000" #tfsec:ignore:general-secrets-no-plaintext-exposure Default set to 90days
}

variable "sm_iam_secret_api_key_persistence" {
  type        = bool
  description = "Whether to use the same service ID and API key for future read operations. Set this to `true` if IAM credentials are managed by the Terraform code."
  default     = true
}

variable "region" {
  type        = string
  description = "Region where resources will be created"
}

variable "service_endpoints" {
  type        = string
  description = "The service endpoint type to communicate with the provided secrets manager instance. Possible values are `public` or `private`"
  default     = "public"
  validation {
    condition     = contains(["public", "private"], var.service_endpoints)
    error_message = "The specified service_endpoints is not a valid selection!"
  }
}

variable "sm_iam_secret_auto_rotation" {
  type        = bool
  description = "Set to `true` to configure automatic rotation policy."
  default     = false
}

variable "sm_iam_secret_auto_rotation_unit" {
  type        = string
  description = "Specifies the unit of time for rotation policy. Acceptable values are `day` or `month`."
  default     = "day" #tfsec:ignore:general-secrets-no-plaintext-exposure
}

variable "sm_iam_secret_auto_rotation_interval" {
  type        = number
  description = "Specifies the rotation interval for the rotation policy."
  default     = 60
}

##############################################################################
