output "ssm_masterkey_path" {
  description = "SSM Parameter Store path for the Zitadel masterkey"
  value       = aws_ssm_parameter.zitadel_masterkey.name
}
