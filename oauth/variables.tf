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
