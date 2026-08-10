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

variable "cnpg_backup_sa_namespace" {
  type    = string
  default = "careerhub-prod"
}

variable "cnpg_backup_sa_name" {
  type        = string
  description = "CNPG Cluster 이름과 동일 — 오퍼레이터가 같은 이름의 SA를 만든다"
  default     = "careerhub-postgresql"
}
