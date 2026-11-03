data "tls_certificate" "k8s_oidc" {
  url = var.k8s_oidc_issuer_url
}

resource "aws_iam_openid_connect_provider" "k8s" {
  url             = var.k8s_oidc_issuer_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.k8s_oidc.certificates[0].sha1_fingerprint]

  tags = {
    Name = "homelab-k8s-oidc"
  }
}
