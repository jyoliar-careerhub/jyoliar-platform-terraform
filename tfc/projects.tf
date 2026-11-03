# 프로젝트 — 워크스페이스가 속하는 묶음이자 env 값의 단위다. 디렉터리 트리(shared/ · lab/ · envs/prod/)대로 나눈다.
# 이 저장소 밖 워크스페이스도 같은 프로젝트에 살 수 있지만, 프로젝트 객체 자체(이름 · 설명)는 여기서 관리한다.
#
# env · region 은 워크스페이스 변수가 아니라 프로젝트가 소유한 variable set 이 주입한다.
# priority = true: 워크스페이스 변수가 같은 키를 덮지 못한다.
# 콘솔에서 만든 옛 조직 소유 set(`common_vars` · `prod-legacy`)은 import 하지 않는다.

locals {
  region = "ap-northeast-2"
}

# tfc 자신이 사는 곳 — Terraform Cloud 가 조직마다 만들어 두는 기본 프로젝트. tfc 에는 env 축이 없어 set 이 없다.
module "project_default" {
  source = "./_modules/project"

  name = "Default Project"
}

# 공유 워크스페이스 — shared/
module "project_shared" {
  source = "./_modules/project"

  name = "shared"

  variable_sets = {
    shared = {
      description = "env · region — shared 프로젝트의 워크스페이스에 주입한다"
      priority    = true
      variables = {
        env    = { value = "shared" }
        region = { value = local.region }
      }
    }
  }
}

# 실험 워크스페이스 — lab/
module "project_lab" {
  source = "./_modules/project"

  name = "lab"

  variable_sets = {
    lab = {
      description = "env · region — lab 프로젝트의 워크스페이스에 주입한다"
      priority    = true
      variables = {
        env    = { value = "lab" }
        region = { value = local.region }
      }
    }
  }
}

# prod 의 careerhub 워크스페이스
module "project_prod_careerhub" {
  source = "./_modules/project"

  name = "prod-careerhub"

  variable_sets = {
    prod = {
      description = "env · region — prod-careerhub 프로젝트의 워크스페이스에 주입한다"
      priority    = true
      variables = {
        env    = { value = "prod" }
        region = { value = local.region }
      }
    }
  }
}
