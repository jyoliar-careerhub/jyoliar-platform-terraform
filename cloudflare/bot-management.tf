# 봇 관리 — 존 전역. AI 크롤러만 차단한다.
# Bot Fight Mode 는 Free 에서 검증 봇 예외가 안 되고 API 호출을 챌린지할 수 있어 끈다(명시).
resource "cloudflare_bot_management" "this" {
  zone_id            = cloudflare_zone.this.id
  ai_bots_protection = "block"
  fight_mode         = false
}
