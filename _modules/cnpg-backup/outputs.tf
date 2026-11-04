output "bucket" {
  description = "S3 bucket name for CloudNativePG backups"
  value       = aws_s3_bucket.this.id
}

output "role_arn" {
  description = "IAM Role ARN for CloudNativePG barman-cloud backup"
  value       = aws_iam_role.this.arn
}
