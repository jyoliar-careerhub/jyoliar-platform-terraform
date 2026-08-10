# CNPG(PostgreSQL) 백업 저장소 — barman-cloud가 base backup + WAL을 적재한다.
# 물리 백업이므로 인스턴스 전체(모든 DB·롤·WAL)가 한 덩어리로 올라간다.
resource "aws_s3_bucket" "cnpg" {
  bucket = "homelab-cnpg-backup-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "homelab-cnpg-backup"
  }
}

# 실수 삭제·덮어쓰기에 대한 마지막 방어선
resource "aws_s3_bucket_versioning" "cnpg" {
  bucket = aws_s3_bucket.cnpg.id

  versioning_configuration {
    status = "Enabled"
  }
}

# SSE-S3(AWS 관리 키) — 복구에 클러스터 외부 재료가 필요하지 않다
resource "aws_s3_bucket_server_side_encryption_configuration" "cnpg" {
  bucket = aws_s3_bucket.cnpg.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "cnpg" {
  bucket = aws_s3_bucket.cnpg.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 백업 객체 자체의 보존은 barman의 retention policy가 관리한다.
# 여기서는 barman이 정리하지 못하는 잔여물(중단된 멀티파트 업로드,
# 버저닝이 남긴 비현행 버전)만 걷어낸다.
resource "aws_s3_bucket_lifecycle_configuration" "cnpg" {
  bucket = aws_s3_bucket.cnpg.id

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

  depends_on = [aws_s3_bucket_versioning.cnpg]
}
