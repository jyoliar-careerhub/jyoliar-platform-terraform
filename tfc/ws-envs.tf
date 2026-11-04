# 환경 워크스페이스 — prod 의 careerhub 리소스. envs/prod/ 아래로 간다 — backup 은 옮겼다.
# zitadel · oauth 의 careerhub 인증 재료는 prod-careerhub(envs/prod/careerhub)로 옮겼고, oauth 에 남았던 admin 파라미터는 shared-admin-oauth 로 재생성했다(ws-shared.tf) — 옛 두 워크스페이스는 지웠다.
#
# env · region 은 워크스페이스 변수가 아니라 prod-careerhub 프로젝트가 소유한 variable set `prod` 가 주입한다(projects.tf).
# 비밀 변수(Google 클라이언트)는 콘솔에 두고 적지 않는다.

# envs/prod/careerhub-backup/ — VCS 연동. iam 의 state 에서 OIDC provider ARN 을 읽는다.
module "backup" {
  source = "./_modules/workspace"

  name                     = "prod-careerhub-backup"
  project_id               = module.project_prod_careerhub.id
  working_directory        = "envs/prod/careerhub-backup"
  vcs                      = local.vcs
  another_trigger_patterns = ["_modules/tfc_remote_state/**/*"]
}

# envs/prod/careerhub/ — VCS 연동. zitadel · oauth 의 careerhub 인증 재료가 _modules/careerhub/auth 로 모여 여기로 온다.
# PostgreSQL 백업 재료(_modules/cnpg-backup)도 여기서 부른다 — shared-iam 의 state 에서 OIDC provider ARN 을 읽는다.
# 이름은 디렉터리 좌표(<env>-<루트>)다 — 프로젝트 이름과 같지만 Terraform Cloud 는 허용한다.
# state 는 옛 zitadel · oauth 워크스페이스에서 state mv 로 옮겨 왔다 — 리소스를 새로 만들지 않았다.
# queue_all_runs = false 는 모듈이 고정한다 — 생성 직후 자동 run 으로 create plan 이 올라가지 않는다.
# Google 클라이언트 값(id · secret · redirect url)은 GCP 콘솔에서 설정한 값을 이 워크스페이스의 콘솔 변수로 둔다.
module "prod_careerhub" {
  source = "./_modules/workspace"

  name                     = "prod-careerhub"
  project_id               = module.project_prod_careerhub.id
  working_directory        = "envs/prod/careerhub"
  vcs                      = local.vcs
  another_trigger_patterns = ["_modules/careerhub/auth/**/*", "_modules/cnpg-backup/**/*", "_modules/tfc_remote_state/**/*"]
}
