output "ssm_masterkey_path" {
  description = "SSM Parameter Store path for the Zitadel masterkey"
  value       = module.auth.ssm_masterkey_path
}

output "ssm_google_client_path" {
  description = "SSM Parameter Store path for Google OAuth credentials (JSON)"
  value       = module.auth.ssm_google_client_path
}

output "cnpg_backup_bucket" {
  description = "S3 bucket name for CloudNativePG backups"
  value       = module.cnpg_backup.bucket
}

output "cnpg_backup_role_arn" {
  description = "IAM Role ARN for CloudNativePG barman-cloud backup"
  value       = module.cnpg_backup.role_arn
}
