locals {
  server_name = "Jyo Liar's Homelab"
  region      = "south-korea"

  alert_channels = {
    info     = { name = "info", position = 0, topic = "Informational alerts" }
    warn     = { name = "warn", position = 1, topic = "Warning alerts - issues requiring attention" }
    critical = { name = "critical", position = 2, topic = "Critical alerts - immediate action required" }
  }
}

data "discord_server" "server" {
  server_id = var.discord_server_id
}

# ──────────────────────────────────────────────
# @everyone: 모든 권한 거부
# ──────────────────────────────────────────────

data "discord_permission" "everyone" {
  view_channel         = "deny"
  read_message_history = "deny"
  send_messages        = "deny"
  send_thread_messages = "deny"
  send_tts_messages    = "deny"
}

resource "discord_role_everyone" "everyone" {
  server_id   = data.discord_server.server.id
  permissions = data.discord_permission.everyone.allow_bits
}

# ──────────────────────────────────────────────
# Alert Viewer role
# ──────────────────────────────────────────────

data "discord_color" "green" {
  hex = "#57F287"
}

data "discord_permission" "alert_viewer" {
  view_channel         = "allow"
  read_message_history = "allow"
}

resource "discord_role" "alert_viewer" {
  server_id   = data.discord_server.server.id
  name        = "Alert Viewer"
  permissions = 0
  color       = data.discord_color.green.dec
  hoist       = false
  mentionable = false
  position    = 1
}

# ──────────────────────────────────────────────
# Category + Channels + Webhooks
# ──────────────────────────────────────────────

resource "discord_category_channel" "alert" {
  name      = "Prometheus Alertmanager"
  position  = 0
  server_id = data.discord_server.server.id
}

resource "discord_channel_permission" "alert_viewer" {
  channel_id   = discord_category_channel.alert.id
  type         = "role"
  overwrite_id = discord_role.alert_viewer.id
  allow        = data.discord_permission.alert_viewer.allow_bits
  deny         = data.discord_permission.alert_viewer.deny_bits
}

resource "discord_text_channel" "alert" {
  for_each = local.alert_channels

  name                     = each.value.name
  position                 = each.value.position
  topic                    = each.value.topic
  server_id                = data.discord_server.server.id
  category                 = discord_category_channel.alert.id
  sync_perms_with_category = true
}

resource "discord_webhook" "alert" {
  for_each = local.alert_channels

  channel_id = discord_text_channel.alert[each.key].id
  name       = "Alertmanager"
}
