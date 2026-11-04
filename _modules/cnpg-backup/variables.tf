variable "namespace" {
  type        = string
  description = "CNPG Cluster가 사는 네임스페이스 — 환경 이름을 이미 든다(careerhub-prod). 이름과 신뢰 정책의 sub가 여기서 파생된다"
}

variable "cluster_name" {
  type        = string
  description = "CNPG Cluster 이름 — 오퍼레이터가 같은 이름의 SA를 만든다. 복구용 <cluster_name>-restore SA도 함께 신뢰한다"
}

variable "k8s_oidc_provider_arn" {
  type        = string
  description = "클러스터의 OIDC 발급자를 신뢰하는 IAM OIDC Provider ARN — shared-iam 의 출력을 루트가 넘긴다"
}

variable "k8s_oidc_issuer_url" {
  type        = string
  description = "OIDC issuer URL for self-managed K8s cluster — 신뢰 정책 조건 키의 호스트 자리"
}
