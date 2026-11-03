# 공유 워크스페이스 — 환경 축이 없는 리소스. shared/ 아래에 있다.
# 이름은 디렉터리 좌표다(shared/<루트> → shared-<루트>). 전부 VCS 연동 — 자기 디렉터리 아래가 바뀔 때 run 이 생긴다.
#
# env · region 은 워크스페이스 변수가 아니라 variable set(onpremise 프로젝트 `common_vars`)으로 주입된다 —
# variable set 은 이 저장소 밖 워크스페이스와 공유되는 조직 수준 객체라 여기서 선언하지 않는다.
# 비밀 변수(Discord 토큰 · Cloudflare API 토큰)는 콘솔에 두고 적지 않는다.

# shared/alert/
module "alert" {
  source = "./_modules/workspace"

  name              = "shared-alert"
  project_id        = tfe_project.onpremise.id
  working_directory = "shared/alert"
  vcs               = local.vcs
  auto_apply        = false

  variables = {
    discord_server_id = { value = "1156141095529500752" }
  }
}

# shared/ci/
module "ci" {
  source = "./_modules/workspace"

  name              = "shared-ci"
  project_id        = tfe_project.onpremise.id
  working_directory = "shared/ci"
  vcs               = local.vcs
  auto_apply        = false
}

# shared/cloudflare/
module "cloudflare" {
  source = "./_modules/workspace"

  name              = "shared-cloudflare"
  project_id        = tfe_project.onpremise.id
  working_directory = "shared/cloudflare"
  vcs               = local.vcs
  auto_apply        = false

  variables = {
    cloudflare_account_id = { value = "1b277f377c35fdff80c7e676cd54be7b" }
  }
}

# shared/iam/ — backup 만 이 state 를 읽는다.
module "iam" {
  source = "./_modules/workspace"

  name                      = "shared-iam"
  project_id                = tfe_project.onpremise.id
  working_directory         = "shared/iam"
  vcs                       = local.vcs
  auto_apply                = false
  remote_state_consumer_ids = [module.backup.id]
}
