terraform {
  # 이 루트만 cloud 블록을 가진다 — tfc 는 다른 워크스페이스를 다스리는 층이라
  # 조직 수준 tfe 토큰을 어느 워크스페이스에도 두지 않고, 운영자의 `terraform login`
  # 자격증명으로 로컬(local 실행 모드)에서 돌린다. state 만 Terraform Cloud 에 둔다.
  cloud {
    organization = "jyoliar"

    workspaces {
      name = "tfc"
    }
  }

  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "0.82.0"
    }
  }
}

# 토큰은 `terraform login` 이 남긴 CLI 자격증명에서 읽는다 — 변수로 받지 않는다.
provider "tfe" {
  organization = local.organization
}
