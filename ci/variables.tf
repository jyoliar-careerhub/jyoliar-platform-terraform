variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "github_org" {
  type        = string
  description = "GitHub Organization name for CodeBuild webhook"
  default     = "jyoliar-careerhub"
}

variable "services" {
  type        = list(string)
  description = "List of service names for ECR repositories (should match GitHub repo names)"
  default = [
    "careerhub-api-composer",
    "careerhub-posting-provider",
    "careerhub-posting-service",
    "careerhub-posting-skillscanner",
    "careerhub-review-crawler",
    "careerhub-review-service",
    "careerhub-userinfo-service",
    "auth-service",
  ]
}
