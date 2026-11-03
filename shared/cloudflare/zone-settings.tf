# 존 설정 — 존 전역이라 프록시되는 모든 호스트(k8s-oidc 등)에 걸린다. 전부 HTTPS 호스트.
resource "cloudflare_zone_setting" "always_use_https" {
  zone_id    = cloudflare_zone.this.id
  setting_id = "always_use_https"
  value      = "on"
}

resource "cloudflare_zone_setting" "min_tls_version" {
  zone_id    = cloudflare_zone.this.id
  setting_id = "min_tls_version"
  value      = "1.2"
}

resource "cloudflare_zone_setting" "security_header" {
  zone_id    = cloudflare_zone.this.id
  setting_id = "security_header"
  value = {
    strict_transport_security = {
      enabled            = true
      max_age            = 15552000 # 180일
      include_subdomains = false
      preload            = false
      nosniff            = false
    }
  }
}
