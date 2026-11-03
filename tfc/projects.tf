# 프로젝트 — 워크스페이스가 속하는 묶음. 이 저장소 밖 워크스페이스도 같은 프로젝트에 살지만,
# 프로젝트 객체 자체(이름 · 설명)는 여기서 관리한다.

# tfc 자신이 사는 곳 — Terraform Cloud 가 조직마다 만들어 두는 기본 프로젝트
resource "tfe_project" "default" {
  name = "Default Project"
}

# 공유 · 실험 워크스페이스
resource "tfe_project" "onpremise" {
  name = "onpremise"
}

# prod 의 careerhub 워크스페이스
resource "tfe_project" "prod_careerhub" {
  name = "prod-careerhub"
}
