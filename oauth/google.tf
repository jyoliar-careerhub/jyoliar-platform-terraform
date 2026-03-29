resource "aws_ssm_parameter" "google_client" {
  name = "/jyo-liar/k8s/baremetal/careerhub/prod/oauth/google-client"
  type = "SecureString"
  value = jsonencode({
    GOOGLE_CLIENT_ID     = var.google_client_id
    GOOGLE_CLIENT_SECRET = var.google_client_secret
    GOOGLE_REDIRECT_URL  = var.google_redirect_url
  })
}
