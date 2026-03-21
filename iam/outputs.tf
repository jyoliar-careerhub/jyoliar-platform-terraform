output "k8s_oidc_provider_arn" {
  description = "ARN of the K8s OIDC Provider"
  value       = aws_iam_openid_connect_provider.k8s.arn
}

output "external_secrets_role_arn" {
  description = "IAM Role ARN for External Secrets Operator"
  value       = aws_iam_role.external_secrets.arn
}

output "ecr_image_puller_role_arn" {
  description = "IAM Role ARN for ECR image pulling"
  value       = aws_iam_role.ecr_image_puller.arn
}
