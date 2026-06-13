variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "google_client_id" {
  type        = string
  description = "Google OAuth Client ID (created manually in GCP Console)"
  sensitive   = true
}

variable "google_client_secret" {
  type        = string
  description = "Google OAuth Client Secret (created manually in GCP Console)"
  sensitive   = true
}

variable "google_redirect_url" {
  type        = string
  description = "Google OAuth redirect URL"
  default     = "https://careerhub.jyo-liar.com/auth/callback/google"
}

variable "admin_google_client_id" {
  type        = string
  description = "관리 콘솔 공용(admin) Google OAuth Client ID (GCP 콘솔에서 수동 생성)"
  sensitive   = true
}

variable "admin_google_client_secret" {
  type        = string
  description = "관리 콘솔 공용(admin) Google OAuth Client Secret"
  sensitive   = true
}
