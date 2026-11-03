# tfc — 이 루트 자신. `terraform init` 이 만들었고(콘솔 생성 아님) 운영자 자격증명으로 로컬에서 돈다.
# 다른 워크스페이스는 shared-ws.tf · envs-ws.tf · lab-ws.tf — 앞으로 옮겨 갈 shared/ · envs/ · lab/ 의 경계다.

# tfc — 이 루트 자신. `terraform init` 이 만들었고(콘솔 생성 아님) 운영자 자격증명으로 로컬에서 돈다.
module "tfc" {
  source = "./_modules/workspace"

  name           = "tfc"
  project_id     = module.project_default.id
  execution_mode = "local"
}
