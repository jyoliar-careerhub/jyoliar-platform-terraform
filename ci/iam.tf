# CodeBuild Service Role
resource "aws_iam_role" "codebuild" {
  name = "homelab-codebuild-runner"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "codebuild.amazonaws.com" }
    }]
  })
}

# ECR Push 권한
resource "aws_iam_role_policy" "codebuild_ecr" {
  name = "ecr-push"
  role = aws_iam_role.codebuild.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
      ]
      Resource = "*"
    }]
  })
}

# CloudWatch Logs (빌드 로그)
resource "aws_iam_role_policy" "codebuild_logs" {
  name = "cloudwatch-logs"
  role = aws_iam_role.codebuild.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
      Resource = "*"
    }]
  })
}

# CodeConnections 사용 권한 (GitHub App 연결)
resource "aws_iam_role_policy" "codebuild_connections" {
  name = "codestar-connections"
  role = aws_iam_role.codebuild.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "codestar-connections:UseConnection",
        "codestar-connections:GetConnection",
        "codestar-connections:GetConnectionToken",
        "codeconnections:UseConnection",
        "codeconnections:GetConnection",
      ]
      Resource = aws_codestarconnections_connection.github.arn
    }]
  })
}

# CodeBuild Webhook 권한
resource "aws_iam_role_policy" "codebuild_webhook" {
  name = "codebuild-webhook"
  role = aws_iam_role.codebuild.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "codebuild:CreateWebhook",
        "codebuild:ProcessWebhook",
      ]
      Resource = aws_codebuild_project.github_actions_runner.arn
    }]
  })
}
