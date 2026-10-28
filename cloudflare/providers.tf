terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.18.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.9.1"
    }
  }
}

provider "cloudflare" {}

provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "ssm"
  region = var.region
}
