output "ssm_slack_webhook_path" {
  description = "SSM Parameter Store path for Discord Slack-compatible webhook URLs"
  value       = aws_ssm_parameter.slack_webhook_url.name
}
