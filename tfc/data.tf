# GitHub App 설치 — vcs_repo 의 github_app_installation_id 가 이것을 쓴다. 설치는 GitHub 쪽 행위라 읽기만 한다.
data "tfe_github_app_installation" "jyoliar_careerhub" {
  name = "jyoliar-careerhub"
}
