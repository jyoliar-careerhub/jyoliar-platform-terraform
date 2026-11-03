# 공유 워크스페이스 — 환경 축이 없는 리소스. shared/ 아래에 있다.
# 이름은 아직 옛 이름이다 — 개명 · VCS 전환은 다음 단계의 것이다.
#
# env · region 은 워크스페이스 변수가 아니라 variable set(onpremise 프로젝트 `common_vars`)으로 주입된다 —
# variable set 은 이 저장소 밖 워크스페이스와 공유되는 조직 수준 객체라 여기서 선언하지 않는다.
# 비밀 변수(Discord 토큰 · Cloudflare API 토큰)는 콘솔에 두고 적지 않는다.

# shared/alert/
module "alert" {
  source = "./_modules/workspace"

  name                  = "onpremise-alert"
  project_id            = tfe_project.onpremise.id
  working_directory     = "shared/alert"
  auto_apply            = false
  file_triggers_enabled = false

  variables = {
    discord_server_id = { value = "1156141095529500752" }
  }
}

# shared/ci/
module "ci" {
  source = "./_modules/workspace"

  name              = "careerhub-ci"
  project_id        = tfe_project.onpremise.id
  working_directory = "shared/ci"
  auto_apply        = false
}

# shared/cloudflare/
module "cloudflare" {
  source = "./_modules/workspace"

  name                  = "platform-cloudflare"
  project_id            = tfe_project.onpremise.id
  working_directory     = "shared/cloudflare"
  auto_apply            = false
  file_triggers_enabled = false

  variables = {
    cloudflare_account_id = { value = "1b277f377c35fdff80c7e676cd54be7b" }
  }
}

# shared/iam/ — backup 만 이 state 를 읽는다.
module "iam" {
  source = "./_modules/workspace"

  name                      = "onpremise-iam"
  project_id                = tfe_project.onpremise.id
  working_directory         = "shared/iam"
  auto_apply                = false
  file_triggers_enabled     = false
  remote_state_consumer_ids = [module.backup.id]
}
