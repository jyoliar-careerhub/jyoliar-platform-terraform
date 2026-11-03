# 워크스페이스가 속한 프로젝트 — 프로젝트 자체는 콘솔 소유, 여기서는 id 만 읽는다.
data "tfe_project" "default" {
  name = "Default Project"
}

data "tfe_project" "onpremise" {
  name = "onpremise"
}

data "tfe_project" "prod_careerhub" {
  name = "prod-careerhub"
}

# GitHub App 설치 — vcs_repo 의 github_app_installation_id 가 이것을 쓴다.
data "tfe_github_app_installation" "jyoliar_careerhub" {
  name = "jyoliar-careerhub"
}
