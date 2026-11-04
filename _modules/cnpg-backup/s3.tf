# CNPG(PostgreSQL) 백업 저장소 — barman-cloud가 base backup + WAL을 적재한다.
# 물리 백업이므로 인스턴스 전체(모든 DB·롤·WAL)가 한 덩어리로 올라간다.
#
# 버저닝은 두지 않는다 — 백업 객체의 보존은 barman retention이 관리하고,
# 버저닝은 비현행 버전과 그 정리 규칙만 더한다.
resource "aws_s3_bucket" "this" {
  bucket = "${local.name}-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = local.name
  }
}

# SSE-S3(AWS 관리 키) — 복구에 클러스터 외부 재료가 필요하지 않다
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }

    # AWS가 2026-04부터 신규 버킷에 SSE-C를 기본 차단한다. 이 값을 비워 두면
    # provider가 "차단 없음"을 의도로 읽어 매 plan마다 차단을 푸는 변경이
    # 딸려 나온다(hashicorp/terraform-provider-aws#47320).
    # 실제 상태를 그대로 적어 둔다 — 차단은 유지하고 드리프트만 없앤다.
    blocked_encryption_types = ["SSE-C"]
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 백업 객체 자체의 보존은 barman의 retention policy가 관리한다.
# 여기서는 barman이 정리하지 못하는 잔여물(중단된 멀티파트 업로드)만 걷어낸다.
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "abort-incomplete-multipart-upload"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}
