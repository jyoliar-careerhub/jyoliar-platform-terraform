# 공유 워크스페이스 — 환경 축이 없는 리소스. 앞으로 shared/ 아래로 간다.
# 지금 이름 · 지금 경로 그대로다 — 이동 · 개명 · VCS 전환은 다음 Task 의 것이다.
#
# env · region 은 워크스페이스 변수가 아니라 variable set(onpremise 프로젝트 `common_vars`)으로 주입된다 —
# variable set 은 이 저장소 밖 워크스페이스와 공유되는 조직 수준 객체라 여기서 선언하지 않는다.
# 비밀 변수(Discord 토큰 · Cloudflare API 토큰)는 콘솔에 두고 적지 않는다.

# alert/
module "alert" {
  source = "./_modules/workspace"

  name                  = "onpremise-alert"
  project_id            = data.tfe_project.onpremise.id
  auto_apply            = false
  file_triggers_enabled = false

  variables = {
    discord_server_id = { value = "1156141095529500752" }
  }
}

# ci/
module "ci" {
  source = "./_modules/workspace"

  name       = "careerhub-ci"
  project_id = data.tfe_project.onpremise.id
  auto_apply = false
}

# cloudflare/
module "cloudflare" {
  source = "./_modules/workspace"

  name                  = "platform-cloudflare"
  project_id            = data.tfe_project.onpremise.id
  auto_apply            = false
  file_triggers_enabled = false

  variables = {
    cloudflare_account_id = { value = "1b277f377c35fdff80c7e676cd54be7b" }
  }
}

# iam/ — backup 만 이 state 를 읽는다.
module "iam" {
  source = "./_modules/workspace"

  name                      = "onpremise-iam"
  project_id                = data.tfe_project.onpremise.id
  auto_apply                = false
  file_triggers_enabled     = false
  remote_state_consumer_ids = [module.backup.id]
}
