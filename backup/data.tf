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
}
