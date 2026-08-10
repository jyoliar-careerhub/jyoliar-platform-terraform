data "aws_caller_identity" "current" {}

# OIDC provider는 iam 워크스페이스가 소유한다 — 여기서는 ARN만 빌려 쓴다.
module "tfc_remote_state" {
  source = "../_modules/tfc_remote_state"

  workspaces = ["onpremise-iam"]
}

locals {
  iam_outputs           = module.tfc_remote_state.outputs["onpremise-iam"]
  k8s_oidc_provider_arn = local.iam_outputs["k8s_oidc_provider_arn"]
  oidc_issuer_host      = replace(var.k8s_oidc_issuer_url, "https://", "")

  # 이름은 전부 주입된 환경 이름에서 파생시킨다 — dev가 추가돼도
  # 버킷·Role·Policy가 환경별로 갈리고 서로 겹치지 않는다.
  # 변수 default로는 다른 변수를 참조할 수 없어 local이어야 한다.
  name_prefix = "homelab-cnpg-backup-${var.env}"

  # 대상 클러스터가 사는 네임스페이스도 환경 이름을 따른다
  # (careerhub-prod / careerhub-dev).
  cnpg_sa_namespace = "${var.cnpg_app_name}-${var.env}"

  # CNPG는 Cluster 이름과 같은 이름의 SA를 만든다. 복구는 원본을 덮어쓰는 것이
  # 아니라 별도 Cluster를 세우는 일이므로, 그 클러스터의 SA도 신뢰해야 한다 —
  # 아니면 복구 훈련을 할 때마다 AWS 변경이 선행되어야 한다.
  # 와일드카드 대신 이름을 열거한다. `<이름>*`로 열면 pooler SA까지 딸려 들어와
  # 백업 버킷 쓰기 권한이 불필요하게 넓어진다.
  cnpg_trusted_subs = [
    "system:serviceaccount:${local.cnpg_sa_namespace}:${var.cnpg_sa_name}",
    "system:serviceaccount:${local.cnpg_sa_namespace}:${var.cnpg_sa_name}-restore",
  ]
}
