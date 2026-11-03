# 워크스페이스 하나 — 모양(tfe_workspace) · 실행 설정(tfe_workspace_settings) · 비밀 아닌 변수(tfe_variable).
# 실행 모드 · remote state 공유는 tfe_workspace 의 deprecated 인자 대신 tfe_workspace_settings 로 선언한다.

locals {
  # VCS 연동이면 자기 working directory 아래가 기본 trigger 다 — 공유 모듈 등은 another_trigger_patterns 로 더한다.
  # CLI 구동이거나 working directory 가 저장소 루트(null)면 기본 패턴은 없다.
  default_trigger_patterns = var.vcs != null && var.working_directory != null ? ["${trimsuffix(var.working_directory, "/")}/**/*"] : []
  trigger_patterns         = concat(local.default_trigger_patterns, var.another_trigger_patterns)
}

resource "tfe_workspace" "this" {
  name              = var.name
  project_id        = var.project_id
  working_directory = var.working_directory

  auto_apply             = var.auto_apply
  auto_apply_run_trigger = var.auto_apply
  file_triggers_enabled  = var.file_triggers_enabled
  trigger_patterns       = local.trigger_patterns

  # provider 기본값(true)이 콘솔(false)과 달라 고정한다 — webhook run 을 첫 수동 run 전까지 큐에 넣지 않는다.
  queue_all_runs = false

  dynamic "vcs_repo" {
    for_each = var.vcs == null ? [] : [var.vcs]

    content {
      identifier                 = vcs_repo.value.identifier
      github_app_installation_id = vcs_repo.value.github_app_installation_id
    }
  }
}

resource "tfe_workspace_settings" "this" {
  workspace_id              = tfe_workspace.this.id
  execution_mode            = var.execution_mode
  global_remote_state       = false
  remote_state_consumer_ids = var.remote_state_consumer_ids
}

resource "tfe_variable" "this" {
  for_each = var.variables

  workspace_id = tfe_workspace.this.id
  key          = each.key
  category     = each.value.category
  hcl          = each.value.hcl
  value        = each.value.value
  sensitive    = false
}
