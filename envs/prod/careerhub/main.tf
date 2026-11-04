# prod 의 careerhub 인증 재료 — 모듈 호출 하나. envs/stg/careerhub 도 같은 블록이고 env 값만 다르다.
module "auth" {
  source = "../../../_modules/careerhub/auth"

  env = var.env

  google_client_id     = var.google_client_id
  google_client_secret = var.google_client_secret
  google_redirect_url  = var.google_redirect_url
}

# OIDC provider 는 shared-iam 워크스페이스가 소유한다 — 여기서는 ARN 만 빌려 쓴다.
module "tfc_remote_state" {
  source = "../../../_modules/tfc_remote_state"

  workspaces = ["shared-iam"]
}

# prod 의 careerhub PostgreSQL 백업 재료 — S3 버킷과 그 IRSA Role. 이름은 모듈이 네임스페이스 · Cluster 이름에서 파생한다.
module "cnpg_backup" {
  source = "../../../_modules/cnpg-backup"

  namespace    = "careerhub-${var.env}"
  cluster_name = "careerhub-postgresql"

  k8s_oidc_provider_arn = module.tfc_remote_state.outputs["shared-iam"]["k8s_oidc_provider_arn"]
  k8s_oidc_issuer_url   = var.k8s_oidc_issuer_url
}
