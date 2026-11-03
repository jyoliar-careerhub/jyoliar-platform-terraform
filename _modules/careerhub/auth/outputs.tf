# 경로만 내보낸다 — 값은 내보내지 않는다.

output "ssm_masterkey_path" {
  description = "SSM Parameter Store path for the Zitadel masterkey"
  value       = aws_ssm_parameter.zitadel_masterkey.name
}

output "ssm_google_client_path" {
  description = "SSM Parameter Store path for Google OAuth credentials (JSON)"
  value       = aws_ssm_parameter.google_client.name
}
