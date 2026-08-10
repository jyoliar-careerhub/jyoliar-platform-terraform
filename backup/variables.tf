variable "env" {
  type        = string
  description = "환경 이름 — 버킷·Role·네임스페이스 이름이 전부 여기서 파생된다"
}

variable "region" {
  type = string
}

variable "k8s_oidc_issuer_url" {
  type        = string
  description = "OIDC issuer URL for self-managed K8s cluster"
  default     = "https://k8s-oidc.jyo-liar.com"
}

variable "cnpg_app_name" {
  type        = string
  description = "CNPG 클러스터가 사는 네임스페이스의 앞자리 — 뒤에 env가 붙는다"
  default     = "careerhub"
}

variable "cnpg_sa_name" {
  type        = string
  description = "CNPG Cluster 이름과 동일 — 오퍼레이터가 같은 이름의 SA를 만든다"
  default     = "careerhub-postgresql"
}
