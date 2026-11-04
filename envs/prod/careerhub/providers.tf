terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.27.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.9.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "0.64.0"
    }
  }
}

provider "aws" {
  default_tags {
    tags = {
      env        = var.env
      managed_by = "terraform"
    }
  }

  region = var.region
}

provider "tfe" {}
