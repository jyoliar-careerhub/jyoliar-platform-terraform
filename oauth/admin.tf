resource "aws_ssm_parameter" "admin_google_client" {
  name = "/jyo-liar/k8s/baremetal/admin/prod/oauth/google-client"
  type = "SecureString"
  value = jsonencode({
    GOOGLE_CLIENT_ID     = var.admin_google_client_id
    GOOGLE_CLIENT_SECRET = var.admin_google_client_secret
  })
}
