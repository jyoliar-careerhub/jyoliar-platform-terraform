variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "k8s_oidc_issuer_url" {
  type        = string
  description = "OIDC issuer URL for self-managed K8s cluster"
  default     = "https://k8s-oidc.jyo-liar.com"
}

variable "external_secrets_sa_namespace" {
  type    = string
  default = "external-secrets"
}

variable "external_secrets_sa_name" {
  type    = string
  default = "external-secrets"
}
