# 환경 워크스페이스 — prod 의 careerhub 리소스. 앞으로 envs/prod/ 아래로 간다.
# zitadel · oauth 는 careerhub-secrets-prod 로 합쳐질 예정이지만, 지금은 콘솔에 있는 그대로 선언한다.
#
# env · region 은 variable set 이 주입한다 — backup · zitadel 은 prod-careerhub 프로젝트의 `prod`, oauth 는 아직 onpremise 프로젝트라 `common_vars`.
# variable set 은 이 저장소 밖과 공유되는 조직 수준 객체라 여기서 선언하지 않는다.
# 비밀 변수(Google 클라이언트)는 콘솔에 두고 적지 않는다.

# backup/ — VCS 연동. iam 의 state 에서 OIDC provider ARN 을 읽는다.
module "backup" {
  source = "./_modules/workspace"

  name              = "prod-careerhub-backup"
  project_id        = data.tfe_project.prod_careerhub.id
  working_directory = "backup"
  vcs               = local.vcs
  trigger_patterns  = ["backup/**/*"]
}

# oauth/ — Terraform Cloud 의 GCP 동적 자격증명(Workload Identity)은 env 변수로 켠다.
module "oauth" {
  source = "./_modules/workspace"

  name                  = "careerhub-oauth"
  project_id            = data.tfe_project.onpremise.id
  working_directory     = "oauth"
  auto_apply            = false
  file_triggers_enabled = false

  variables = {
    TFC_GCP_PROVIDER_AUTH             = { category = "env", value = "true" }
    TFC_GCP_WORKLOAD_PROVIDER_NAME    = { category = "env", value = "projects/812085830791/locations/global/workloadIdentityPools/terraform-cloud/providers/terraform-cloud" }
    TFC_GCP_RUN_SERVICE_ACCOUNT_EMAIL = { category = "env", value = "terraform@careerhub-417808.iam.gserviceaccount.com" }
  }
}

# zitadel/ — VCS 연동
module "zitadel" {
  source = "./_modules/workspace"

  name              = "prod-careerhub-zitadel"
  project_id        = data.tfe_project.prod_careerhub.id
  working_directory = "zitadel"
  vcs               = local.vcs
  trigger_patterns  = ["zitadel/**/*"]
}
