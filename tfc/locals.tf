locals {
  organization = "jyoliar"

  # VCS 연동 워크스페이스가 가리키는 저장소 — 이 저장소 자신이다.
  repo = "jyoliar-careerhub/jyoliar-platform-terraform"

  # VCS 연동 워크스페이스에 넘기는 연결 — 저장소와 GitHub App 설치
  vcs = {
    identifier                 = local.repo
    github_app_installation_id = data.tfe_github_app_installation.jyoliar_careerhub.id
  }
}
