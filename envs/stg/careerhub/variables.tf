# env · region 은 선언만 한다 — 값은 stg-careerhub 프로젝트의 variable set 이 준다.
variable "env" {
  type = string
}

variable "region" {
  type = string
}

# Google 클라이언트 값은 terraform 이 관리하지 않는다 — GCP 콘솔에서 설정한 값을 워크스페이스 변수(콘솔)로 받는다.
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

variable "k8s_oidc_issuer_url" {
  type        = string
  description = "OIDC issuer URL for self-managed K8s cluster"
  default     = "https://k8s-oidc.jyo-liar.com"
}
