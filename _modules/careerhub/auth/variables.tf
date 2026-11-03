variable "env" {
  type        = string
  description = "환경 이름 — SSM 경로의 환경 자리가 여기서 파생된다"
}

# Google 클라이언트 값은 terraform 이 관리하지 않는다 — GCP 콘솔에서 설정한 값을 받는다. 기본값을 두지 않는다.
variable "google_client_id" {
  type        = string
  description = "Google OAuth Client ID (GCP 콘솔에서 수동 생성)"
  sensitive   = true
}

variable "google_client_secret" {
  type        = string
  description = "Google OAuth Client Secret (GCP 콘솔에서 수동 생성)"
  sensitive   = true
}

variable "google_redirect_url" {
  type        = string
  description = "Google OAuth redirect URL (GCP 콘솔에서 설정한 값)"
}
