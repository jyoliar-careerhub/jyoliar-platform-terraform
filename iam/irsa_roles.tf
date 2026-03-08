# External Secrets Operator용 IRSA Role
resource "aws_iam_role" "external_secrets" {
  name = "homelab-k8s-external-secrets"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.k8s.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.k8s_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:${var.external_secrets_sa_namespace}:${var.external_secrets_sa_name}"
            "${replace(var.k8s_oidc_issuer_url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

# 기존 Parameter Store 읽기 정책을 IRSA Role에 연결
resource "aws_iam_role_policy_attachment" "external_secrets_ssm" {
  role       = aws_iam_role.external_secrets.name
  policy_arn = aws_iam_policy.k8s_parameter_store_read.arn
}
