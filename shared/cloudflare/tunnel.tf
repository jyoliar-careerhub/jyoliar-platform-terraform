resource "random_bytes" "tunnel" {
  length = 32
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "k8s_oidc" {
  account_id    = var.cloudflare_account_id
  name          = "k8s-oidc"
  config_src    = "local"
  tunnel_secret = random_bytes.tunnel.base64
}

resource "cloudflare_dns_record" "k8s_oidc" {
  zone_id = cloudflare_zone.this.id
  name    = "k8s-oidc"
  type    = "CNAME"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.k8s_oidc.id}.cfargotunnel.com"
  proxied = true
  ttl     = 1
}

# 터널을 가리키는 안정 이름 — GitOps 쪽(external-dns target)은 UUID 대신 이 이름만 안다.
resource "cloudflare_dns_record" "cftunnel" {
  zone_id = cloudflare_zone.this.id
  name    = "cftunnel"
  type    = "CNAME"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.k8s_oidc.id}.cfargotunnel.com"
  proxied = true
  ttl     = 1
}
