##############################################################################
# Outputs
##############################################################################

output "secret_id" {
  value       = ibm_sm_iam_credentials_secret.sm_iam_credentials_secret.secret_id
  description = "Secrets-Manager IAM secret ID containing ServiceID API key"
}

output "sm_iam_secret_next_rotation_date" {
  description = "Next rotation date for iam_credential secret"
  value       = ibm_sm_iam_credentials_secret.sm_iam_credentials_secret.next_rotation_date
}

##############################################################################
