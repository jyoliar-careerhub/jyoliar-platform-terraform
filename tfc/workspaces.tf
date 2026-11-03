# 워크스페이스 선언 — 이름 · working_directory · VCS 연결 · 트리거 · 실행 모드 · remote state 소비자.
# 지금 이름 · 지금 경로 그대로다. 디렉터리 이동 · 개명 · VCS 전환은 다음 Task 의 것이다.
#
# 실행 모드 · remote state 공유는 tfe_workspace 의 deprecated 인자 대신 tfe_workspace_settings 로 선언한다.
# queue_all_runs 는 provider 기본값(true)이 콘솔(false)과 달라 전부 명시한다.

# ---------------------------------------------------------------------------
# tfc — 이 루트 자신. `terraform init` 이 만들었고(콘솔 생성 아님) local 실행이다.
# ---------------------------------------------------------------------------

resource "tfe_workspace" "tfc" {
  name           = "tfc"
  project_id     = data.tfe_project.default.id
  queue_all_runs = false

  # 자기 state 의 보관소다 — 이 선언으로 지워지면 안 된다.
  lifecycle {
    prevent_destroy = true
  }
}

resource "tfe_workspace_settings" "tfc" {
  workspace_id   = tfe_workspace.tfc.id
  execution_mode = "local"
}

# ---------------------------------------------------------------------------
# alert/ — onpremise-alert
# ---------------------------------------------------------------------------

resource "tfe_workspace" "alert" {
  name                  = "onpremise-alert"
  project_id            = data.tfe_project.onpremise.id
  queue_all_runs        = false
  file_triggers_enabled = false
}

resource "tfe_workspace_settings" "alert" {
  workspace_id   = tfe_workspace.alert.id
  execution_mode = "remote"
}

# ---------------------------------------------------------------------------
# backup/ — prod-careerhub-backup (VCS 연동 · auto-apply)
# ---------------------------------------------------------------------------

resource "tfe_workspace" "backup" {
  name                   = "prod-careerhub-backup"
  project_id             = data.tfe_project.prod_careerhub.id
  working_directory      = "backup"
  queue_all_runs         = false
  auto_apply             = true
  auto_apply_run_trigger = true
  trigger_patterns       = ["backup/**/*"]

  vcs_repo {
    identifier                 = local.repo
    github_app_installation_id = data.tfe_github_app_installation.jyoliar_careerhub.id
  }
}

resource "tfe_workspace_settings" "backup" {
  workspace_id   = tfe_workspace.backup.id
  execution_mode = "remote"
}

# ---------------------------------------------------------------------------
# ci/ — careerhub-ci
# ---------------------------------------------------------------------------

resource "tfe_workspace" "ci" {
  name           = "careerhub-ci"
  project_id     = data.tfe_project.onpremise.id
  queue_all_runs = false
}

resource "tfe_workspace_settings" "ci" {
  workspace_id   = tfe_workspace.ci.id
  execution_mode = "remote"
}

# ---------------------------------------------------------------------------
# cloudflare/ — platform-cloudflare
# ---------------------------------------------------------------------------

resource "tfe_workspace" "cloudflare" {
  name                  = "platform-cloudflare"
  project_id            = data.tfe_project.onpremise.id
  queue_all_runs        = false
  file_triggers_enabled = false
}

resource "tfe_workspace_settings" "cloudflare" {
  workspace_id   = tfe_workspace.cloudflare.id
  execution_mode = "remote"
}

# ---------------------------------------------------------------------------
# iam/ — onpremise-iam. backup 이 OIDC provider ARN 을 이 state 에서 읽는다.
# ---------------------------------------------------------------------------

resource "tfe_workspace" "iam" {
  name                  = "onpremise-iam"
  project_id            = data.tfe_project.onpremise.id
  queue_all_runs        = false
  file_triggers_enabled = false
}

resource "tfe_workspace_settings" "iam" {
  workspace_id              = tfe_workspace.iam.id
  execution_mode            = "remote"
  global_remote_state       = false
  remote_state_consumer_ids = [tfe_workspace.backup.id]
}

# ---------------------------------------------------------------------------
# oauth/ — careerhub-oauth
# ---------------------------------------------------------------------------

resource "tfe_workspace" "oauth" {
  name                  = "careerhub-oauth"
  project_id            = data.tfe_project.onpremise.id
  working_directory     = "oauth"
  queue_all_runs        = false
  file_triggers_enabled = false
}

resource "tfe_workspace_settings" "oauth" {
  workspace_id   = tfe_workspace.oauth.id
  execution_mode = "remote"
}

# ---------------------------------------------------------------------------
# vpc/ — onpremise-vpc. vpn 이 네트워크 출력을 이 state 에서 읽는다.
# ---------------------------------------------------------------------------

resource "tfe_workspace" "vpc" {
  name              = "onpremise-vpc"
  project_id        = data.tfe_project.onpremise.id
  working_directory = "vpc"
  queue_all_runs    = false
}

resource "tfe_workspace_settings" "vpc" {
  workspace_id              = tfe_workspace.vpc.id
  execution_mode            = "remote"
  global_remote_state       = false
  remote_state_consumer_ids = [tfe_workspace.vpn.id]
}

# ---------------------------------------------------------------------------
# vpn/ — onpremise-vpn
# ---------------------------------------------------------------------------

resource "tfe_workspace" "vpn" {
  name                  = "onpremise-vpn"
  project_id            = data.tfe_project.onpremise.id
  working_directory     = "vpn/"
  queue_all_runs        = false
  file_triggers_enabled = false
}

resource "tfe_workspace_settings" "vpn" {
  workspace_id   = tfe_workspace.vpn.id
  execution_mode = "remote"
}

# ---------------------------------------------------------------------------
# zitadel/ — prod-careerhub-zitadel (VCS 연동 · auto-apply)
# ---------------------------------------------------------------------------

resource "tfe_workspace" "zitadel" {
  name                   = "prod-careerhub-zitadel"
  project_id             = data.tfe_project.prod_careerhub.id
  working_directory      = "zitadel"
  queue_all_runs         = false
  auto_apply             = true
  auto_apply_run_trigger = true
  trigger_patterns       = ["zitadel/**/*"]

  vcs_repo {
    identifier                 = local.repo
    github_app_installation_id = data.tfe_github_app_installation.jyoliar_careerhub.id
  }
}

resource "tfe_workspace_settings" "zitadel" {
  workspace_id   = tfe_workspace.zitadel.id
  execution_mode = "remote"
}
