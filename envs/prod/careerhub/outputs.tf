output "ssm_masterkey_path" {
  description = "SSM Parameter Store path for the Zitadel masterkey"
  value       = module.auth.ssm_masterkey_path
}

output "ssm_google_client_path" {
  description = "SSM Parameter Store path for Google OAuth credentials (JSON)"
  value       = module.auth.ssm_google_client_path
}
