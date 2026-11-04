# argocd · grafana 로그인이 함께 쓰는 Google 클라이언트 — 환경 축이 없어 경로에 env 를 넣지 않는다.
# 소비자: jyoliar-k8s 의 ExternalSecret argocd-oidc-google(argocd) · grafana-oauth(prometheus).
resource "aws_ssm_parameter" "admin_google_client" {
  name = "/jyo-liar/k8s/baremetal/admin/oauth/google-client"
  type = "SecureString"
  value = jsonencode({
    GOOGLE_CLIENT_ID     = var.admin_google_client_id
    GOOGLE_CLIENT_SECRET = var.admin_google_client_secret
  })
}
