# 워크스페이스 변수 — 비밀 아닌 것(sensitive = false)만 선언한다.
# 비밀(Discord 토큰 · Cloudflare API 토큰 · Google 클라이언트 · Tailscale 키)은 콘솔에 두고 여기 적지 않는다.
#
# env · region 은 워크스페이스 변수가 아니라 variable set(onpremise 프로젝트 `common_vars` · prod-careerhub 프로젝트 `prod`)
# 으로 주입된다 — variable set 은 이 저장소 밖 워크스페이스와 공유되는 조직 수준 객체라 여기서 선언하지 않는다.

# alert — Discord 서버
resource "tfe_variable" "alert_discord_server_id" {
  workspace_id = tfe_workspace.alert.id
  category     = "terraform"
  key          = "discord_server_id"
  value        = "1156141095529500752"
}

# cloudflare — 계정
resource "tfe_variable" "cloudflare_account_id" {
  workspace_id = tfe_workspace.cloudflare.id
  category     = "terraform"
  key          = "cloudflare_account_id"
  value        = "1b277f377c35fdff80c7e676cd54be7b"
}

# oauth — Terraform Cloud 의 GCP 동적 자격증명(Workload Identity)
resource "tfe_variable" "oauth_tfc_gcp_provider_auth" {
  workspace_id = tfe_workspace.oauth.id
  category     = "env"
  key          = "TFC_GCP_PROVIDER_AUTH"
  value        = "true"
}

resource "tfe_variable" "oauth_tfc_gcp_workload_provider_name" {
  workspace_id = tfe_workspace.oauth.id
  category     = "env"
  key          = "TFC_GCP_WORKLOAD_PROVIDER_NAME"
  value        = "projects/812085830791/locations/global/workloadIdentityPools/terraform-cloud/providers/terraform-cloud"
}

resource "tfe_variable" "oauth_tfc_gcp_run_service_account_email" {
  workspace_id = tfe_workspace.oauth.id
  category     = "env"
  key          = "TFC_GCP_RUN_SERVICE_ACCOUNT_EMAIL"
  value        = "terraform@careerhub-417808.iam.gserviceaccount.com"
}

# vpn — 노드 접속 키 · 다른 사이트 CIDR
resource "tfe_variable" "vpn_ssh_public_key" {
  workspace_id = tfe_workspace.vpn.id
  category     = "terraform"
  key          = "ssh_public_key"
  value        = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDMX2GVbPKMl/ZORgK/LHdpd9LFKK1m5sLy+UER11RNXsu8GpDFkXfGibf4QrYCSznTtA/2+3VyEPY3zEfXJmaUbZ6Ynk9zH1c8L8IFyeChQC+eMJKgDIh/7vI6msVRCJY3uqFdtswvcoSQNrFV8QCfTOTCWIt9Mlnar484a0dW3hJoPipTCTRvU9peMB+3wHJ5LevY5LUgfc6tAVFj+g4DZs3W9Fvz6ZsbGD+Uk27ttTgqrxaPuGvTsJmC4cSrfKq9VUdaEsgAmgZrZNOOr2FAScTuqzclIB8jF47MZ3oCKxUClr93RAb/rtKXqzMGCnOQQDZg9BXp5cFS6OUGX6mmBIYIEnmkTsK7m3s29A7qr4CtPE6kWvkxC4zT/zcrAvNLXzytIbJMGkIlY0cMkyf/v75fZHmhYEEm7j7pI7YEAvL2Xmoshso17y4g8goPsewUbaC5mjcFB2I9g4+bgZVWbAAVKU+OuuHdT3pJWaeDjpfOZKTrywo2uN/FqjIDgC46aXKyubi5z/wmBtxI6qe+ChI43g15MeRTasU7Oe2XdyjNwkbNVCiw5LWqunbQq06GpFKsTo9apH2o+d2s9jGV2lKeMgzFKJ8PfPg+LUuTcJOVZ36LQVRfOAAhkX30GXlkFgRNI0GR72n5CAdd6CB5znNBzNTtltXxLyTO8rLAHw=="
}

resource "tfe_variable" "vpn_other_site_cidr_blocks" {
  workspace_id = tfe_workspace.vpn.id
  category     = "terraform"
  key          = "other_site_cidr_blocks"
  hcl          = true
  value        = "[\"10.18.0.0/16\"]"
}
