# CodeBuild 프로젝트 — GitHub Actions self-hosted runner (Organization-wide)
resource "aws_codebuild_project" "github_actions_runner" {
  name         = "homelab-app-builder"
  description  = "GitHub Actions self-hosted runner for homelab K8s apps (Organization-wide)"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL" # 프리티어 대상 (arm1.small)
    image           = "aws/codebuild/amazonlinux-aarch64-standard:3.0"
    type            = "ARM_CONTAINER"
    privileged_mode = true # Docker 빌드에 필요
  }

  source {
    type      = "GITHUB"
    location  = "CODEBUILD_DEFAULT_WEBHOOK_SOURCE_LOCATION"
    buildspec = ""
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.codebuild.name
    }
  }
}

resource "aws_cloudwatch_log_group" "codebuild" {
  name              = "/codebuild/homelab-app-builder"
  retention_in_days = 14
}

# Organization Webhook — 조직 전체 레포에서 WORKFLOW_JOB_QUEUED 이벤트 수신
resource "aws_codebuild_webhook" "github_actions" {
  project_name = aws_codebuild_project.github_actions_runner.name

  scope_configuration {
    scope = "GITHUB_ORGANIZATION"
    name  = var.github_org
  }

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "WORKFLOW_JOB_QUEUED"
    }
  }
}
