# Google Search Console 도메인 속성(jyo-liar.com) 소유 확인 — 루트 등재를 보는 유일한 창구.
# 확인 상태 유지에 레코드가 계속 있어야 하므로 지우지 않는다.
resource "cloudflare_dns_record" "google_site_verification" {
  zone_id = cloudflare_zone.this.id
  name    = "@"
  type    = "TXT"
  content = "\"google-site-verification=DrO47gp0sJ4NV68m-EsEdHSCf8XpUcFpZfSgcsoZO8g\""
  ttl     = 3600
}
