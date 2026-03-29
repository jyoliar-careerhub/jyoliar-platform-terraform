output "ssm_google_client_path" {
  description = "SSM Parameter Store path for Google OAuth credentials (JSON)"
  value       = aws_ssm_parameter.google_client.name
}
