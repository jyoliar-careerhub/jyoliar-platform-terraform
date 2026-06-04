output "ssm_slack_webhook_path" {
  description = "SSM Parameter Store path for Discord Slack-compatible webhook URLs"
  value       = aws_ssm_parameter.slack_webhook_url.name
}

output "ssm_ai_agent_webhook_path" {
  description = "SSM Parameter Store path for the AI agent Discord webhook URL (single slack_url)"
  value       = aws_ssm_parameter.ai_agent_webhook_url.name
}
