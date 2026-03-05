output "webhook_urls" {
  value     = { for key, wh in discord_webhook.alert : key => wh.slack_url }
  sensitive = true
}
