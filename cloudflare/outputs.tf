output "zone_id" {
  value = cloudflare_zone.this.id
}

output "name_servers" {
  value = cloudflare_zone.this.name_servers
}

output "tunnel_credentials" {
  value = jsonencode({
    AccountTag   = var.cloudflare_account_id
    TunnelID     = cloudflare_zero_trust_tunnel_cloudflared.k8s_oidc.id
    TunnelSecret = random_bytes.tunnel.base64
  })
  sensitive = true
}
