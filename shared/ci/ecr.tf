# ECR 레포지토리 — 서비스별 컨테이너 이미지 저장소
resource "aws_ecr_repository" "apps" {
  for_each = toset(var.services)

  name                 = each.key
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# 오래된 이미지 자동 정리 — 최근 10개만 유지
resource "aws_ecr_lifecycle_policy" "apps" {
  for_each   = aws_ecr_repository.apps
  repository = each.value.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 10 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
      action = { type = "expire" }
    }]
  })
}
