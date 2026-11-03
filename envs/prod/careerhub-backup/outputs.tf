output "cnpg_backup_bucket" {
  description = "S3 bucket name for CloudNativePG backups"
  value       = aws_s3_bucket.cnpg.id
}

output "cnpg_backup_role_arn" {
  description = "IAM Role ARN for CloudNativePG barman-cloud backup"
  value       = aws_iam_role.cnpg_backup.arn
}
