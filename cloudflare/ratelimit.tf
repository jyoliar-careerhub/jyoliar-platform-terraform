# 레이트리밋 — Free 플랜 한도: 규칙 1개 · 집계 10초 · 완화 10초 · 특성 IP.
# cf.colo.id 는 API 가 요구하는 필수 특성이다(데이터센터별 집계, 묵시 포함).
resource "cloudflare_ruleset" "ratelimit" {
  zone_id = cloudflare_zone.this.id
  name    = "ratelimit"
  kind    = "zone"
  phase   = "http_ratelimit"

  rules = [{
    ref         = "careerhub_api"
    description = "careerhub /api/ — IP 당 10초에 50회"
    expression  = "(http.host eq \"careerhub.jyo-liar.com\" and starts_with(http.request.uri.path, \"/api/\"))"
    action      = "block"
    enabled     = true

    ratelimit = {
      characteristics     = ["cf.colo.id", "ip.src"]
      period              = 10
      requests_per_period = 50 # 초기값 — 운영 중 값만 바꾼다
      mitigation_timeout  = 10
    }
  }]
}
