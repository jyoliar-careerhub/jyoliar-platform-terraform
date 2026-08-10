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
}
