# CNPG 백업용 IRSA Role — 대상 환경의 CNPG 인스턴스 파드 SA가 위임받는다.
# 이 클러스터에는 EKS pod-identity webhook이 없으므로, 파드 쪽에서
# AWS_ROLE_ARN·AWS_WEB_IDENTITY_TOKEN_FILE과 sts.amazonaws.com audience의
# projected token을 직접 주입한다(external-secrets와 같은 방식).
resource "aws_iam_role" "cnpg_backup" {
  name = local.name_prefix

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = local.k8s_oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${local.oidc_issuer_host}:sub" = local.cnpg_trusted_subs
            "${local.oidc_issuer_host}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "cnpg_backup" {
  name        = "${local.name_prefix}-policy"
  description = "Policy for CloudNativePG barman-cloud backup to S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:ListBucketMultipartUploads"
        ]
        Resource = aws_s3_bucket.cnpg.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ]
        Resource = "${aws_s3_bucket.cnpg.arn}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cnpg_backup" {
  role       = aws_iam_role.cnpg_backup.name
  policy_arn = aws_iam_policy.cnpg_backup.arn
}
