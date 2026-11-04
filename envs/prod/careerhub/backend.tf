# 로컬 CLI 바인딩 — `terraform init` 이 이 워크스페이스에 붙는다. 러너는 이 블록을 쓰지 않는다
# (원격 run 은 HCP Terraform 이 주입한 백엔드로 돈다). 이름은 tfc/ 의 tfe_workspace 이름과 같아야 한다 —
# 틀리면 로컬 state mv · import · state push 가 다른 워크스페이스의 state 를 친다.
terraform {
  cloud {
    organization = "jyoliar"

    workspaces {
      name = "prod-careerhub"
    }
  }
}
