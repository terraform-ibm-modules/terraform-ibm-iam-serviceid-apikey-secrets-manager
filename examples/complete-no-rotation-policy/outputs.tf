output "sm_iam_secret_puller_apikey_secret_id" {
  value       = module.dynamic_serviceid_apikey1.secret_id
  description = "Secrets-Manager IAM secret ID containing ServiceID API key"
}

output "secrets_manager_crn" {
  value       = module.secrets_manager.secrets_manager_crn
  description = "CRN of Secrets-Manager instance in which IAM engine was configured"
}

output "service_secret_group_id" {
  value       = module.secrets_manager_group_service.secret_group_id
  description = "Secret-group ID containing IAM secret"
}
