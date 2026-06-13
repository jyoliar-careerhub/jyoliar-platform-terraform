output "ssm_google_client_path" {
  description = "SSM Parameter Store path for Google OAuth credentials (JSON)"
  value       = aws_ssm_parameter.google_client.name
}

output "ssm_admin_google_client_path" {
  description = "SSM Parameter Store path for admin console shared Google OAuth credentials (JSON)"
  value       = aws_ssm_parameter.admin_google_client.name
}
