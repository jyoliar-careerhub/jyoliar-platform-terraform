output "codebuild_project_name" {
  description = "CodeBuild project name (used in GitHub Actions runs-on label)"
  value       = aws_codebuild_project.github_actions_runner.name
}

output "codebuild_project_arn" {
  description = "CodeBuild project ARN"
  value       = aws_codebuild_project.github_actions_runner.arn
}

output "github_connection_arn" {
  description = "CodeConnections connection ARN (GitHub App)"
  value       = aws_codestarconnections_connection.github.arn
}

output "github_connection_status" {
  description = "CodeConnections connection status (Pending → Available after console approval)"
  value       = aws_codestarconnections_connection.github.connection_status
}

output "ecr_repository_urls" {
  description = "ECR repository URLs per service"
  value       = { for k, v in aws_ecr_repository.apps : k => v.repository_url }
}

output "codebuild_role_arn" {
  description = "IAM Role ARN for CodeBuild"
  value       = aws_iam_role.codebuild.arn
}
