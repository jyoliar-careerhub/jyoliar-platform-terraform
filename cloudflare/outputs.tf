output "zone_id" {
  value = cloudflare_zone.this.id
}

output "name_servers" {
  value = cloudflare_zone.this.name_servers
}

data "cloudflare_zero_trust_tunnel_cloudflared_token" "k8s_oidc" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.k8s_oidc.id
}

output "tunnel_token" {
  value     = data.cloudflare_zero_trust_tunnel_cloudflared_token.k8s_oidc.token
  sensitive = true
}
