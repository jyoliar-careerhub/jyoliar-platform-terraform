# 실험 워크스페이스 — AWS 모의 환경. lab/ 아래에 있다.
# 전부 VCS 연동 — 자기 디렉터리와 쓰는 공유 모듈 아래가 바뀔 때 run 이 생긴다.
# env · region 은 variable set `common_vars` 가 주입한다. 비밀 변수(Tailscale 키)는 콘솔에 둔다.

# lab/vpc/ — vpn 만 이 state 를 읽는다.
module "vpc" {
  source = "./_modules/workspace"

  name                      = "lab-vpc"
  project_id                = tfe_project.onpremise.id
  working_directory         = "lab/vpc"
  vcs                       = local.vcs
  remote_state_consumer_ids = [module.vpn.id]
}

# lab/vpn/
module "vpn" {
  source = "./_modules/workspace"

  name                     = "lab-vpn"
  project_id               = tfe_project.onpremise.id
  working_directory        = "lab/vpn"
  vcs                      = local.vcs
  another_trigger_patterns = ["_modules/tfc_remote_state/**/*", "_modules/nat/**/*"]

  variables = {
    ssh_public_key         = { value = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDMX2GVbPKMl/ZORgK/LHdpd9LFKK1m5sLy+UER11RNXsu8GpDFkXfGibf4QrYCSznTtA/2+3VyEPY3zEfXJmaUbZ6Ynk9zH1c8L8IFyeChQC+eMJKgDIh/7vI6msVRCJY3uqFdtswvcoSQNrFV8QCfTOTCWIt9Mlnar484a0dW3hJoPipTCTRvU9peMB+3wHJ5LevY5LUgfc6tAVFj+g4DZs3W9Fvz6ZsbGD+Uk27ttTgqrxaPuGvTsJmC4cSrfKq9VUdaEsgAmgZrZNOOr2FAScTuqzclIB8jF47MZ3oCKxUClr93RAb/rtKXqzMGCnOQQDZg9BXp5cFS6OUGX6mmBIYIEnmkTsK7m3s29A7qr4CtPE6kWvkxC4zT/zcrAvNLXzytIbJMGkIlY0cMkyf/v75fZHmhYEEm7j7pI7YEAvL2Xmoshso17y4g8goPsewUbaC5mjcFB2I9g4+bgZVWbAAVKU+OuuHdT3pJWaeDjpfOZKTrywo2uN/FqjIDgC46aXKyubi5z/wmBtxI6qe+ChI43g15MeRTasU7Oe2XdyjNwkbNVCiw5LWqunbQq06GpFKsTo9apH2o+d2s9jGV2lKeMgzFKJ8PfPg+LUuTcJOVZ36LQVRfOAAhkX30GXlkFgRNI0GR72n5CAdd6CB5znNBzNTtltXxLyTO8rLAHw==" }
    other_site_cidr_blocks = { value = "[\"10.18.0.0/16\"]", hcl = true }
  }
}
