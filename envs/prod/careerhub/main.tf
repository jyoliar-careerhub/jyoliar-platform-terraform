# prod 의 careerhub 인증 재료 — 모듈 호출 하나. envs/stg/careerhub 도 같은 블록이고 env 값만 다르다.
module "auth" {
  source = "../../../_modules/careerhub/auth"

  env = var.env

  google_client_id     = var.google_client_id
  google_client_secret = var.google_client_secret
  google_redirect_url  = var.google_redirect_url
}
