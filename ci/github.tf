# GitHub App 연결 (CodeConnections)
# terraform apply 후 AWS 콘솔에서 연결 승인 필요 (최초 1회)
resource "aws_codestarconnections_connection" "github" {
  name          = "homelab-github-connection"
  provider_type = "GitHub"
}

# CodeBuild가 GitHub 접근 시 위 Connection을 사용하도록 계정 수준에서 등록
resource "aws_codebuild_source_credential" "github" {
  auth_type   = "CODECONNECTIONS"
  server_type = "GITHUB"
  token       = aws_codestarconnections_connection.github.arn
}

output "connection_status" {
  value = aws_codestarconnections_connection.github.connection_status
}

output "codestarconnections_arn" {
  value = aws_codestarconnections_connection.github.arn
}
