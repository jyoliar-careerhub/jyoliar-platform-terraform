data "aws_caller_identity" "current" {}

# CNPG(PostgreSQL) 백업 저장소 — barman-cloud가 base backup + WAL을 적재한다.
# 물리 백업이므로 인스턴스 전체(모든 DB·롤·WAL)가 한 덩어리로 올라간다.
resource "aws_s3_bucket" "cnpg_backup" {
  bucket = "homelab-cnpg-backup-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "homelab-cnpg-backup"
  }
}

# 실수 삭제·덮어쓰기에 대한 마지막 방어선
resource "aws_s3_bucket_versioning" "cnpg_backup" {
  bucket = aws_s3_bucket.cnpg_backup.id

  versioning_configuration {
    status = "Enabled"
  }
}

# SSE-S3(AWS 관리 키) — 복구에 클러스터 외부 재료가 필요하지 않다
resource "aws_s3_bucket_server_side_encryption_configuration" "cnpg_backup" {
  bucket = aws_s3_bucket.cnpg_backup.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "cnpg_backup" {
  bucket = aws_s3_bucket.cnpg_backup.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 백업 객체 자체의 보존은 barman의 retention policy가 관리한다.
# 여기서는 barman이 정리하지 못하는 잔여물(중단된 멀티파트 업로드,
# 버저닝이 남긴 비현행 버전)만 걷어낸다.
resource "aws_s3_bucket_lifecycle_configuration" "cnpg_backup" {
  bucket = aws_s3_bucket.cnpg_backup.id

  rule {
    id     = "abort-incomplete-multipart-upload"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  rule {
    id     = "expire-noncurrent-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }

  depends_on = [aws_s3_bucket_versioning.cnpg_backup]
}

# CNPG 백업용 IRSA Role — careerhub-postgresql 인스턴스 파드의 SA가 위임받는다.
# 이 클러스터에는 EKS pod-identity webhook이 없으므로, 파드 쪽에서
# AWS_ROLE_ARN·AWS_WEB_IDENTITY_TOKEN_FILE과 sts.amazonaws.com audience의
# projected token을 직접 주입한다(external-secrets와 같은 방식).
resource "aws_iam_role" "cnpg_backup" {
  name = "homelab-k8s-cnpg-backup"

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
            "${replace(var.k8s_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:${var.cnpg_backup_sa_namespace}:${var.cnpg_backup_sa_name}"
            "${replace(var.k8s_oidc_issuer_url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "cnpg_backup" {
  name        = "k8s-cnpg-backup-policy"
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
        Resource = aws_s3_bucket.cnpg_backup.arn
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
        Resource = "${aws_s3_bucket.cnpg_backup.arn}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cnpg_backup" {
  role       = aws_iam_role.cnpg_backup.name
  policy_arn = aws_iam_policy.cnpg_backup.arn
}
