resource "cloudflare_zero_trust_tunnel_cloudflared" "k8s_oidc" {
  account_id = var.cloudflare_account_id
  name       = "k8s-oidc"
  config_src = "cloudflare"
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "k8s_oidc" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.k8s_oidc.id

  config = {
    ingress = [
      {
        hostname = "k8s-oidc.${var.domain}"
        service  = "http://oidc-server.oidc-provider.svc.cluster.local:8080"
      },
      {
        service = "http_status:404"
      },
    ]
  }
}

resource "cloudflare_dns_record" "k8s_oidc" {
  zone_id = cloudflare_zone.this.id
  name    = "k8s-oidc"
  type    = "CNAME"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.k8s_oidc.id}.cfargotunnel.com"
  proxied = true
  ttl     = 1
}
