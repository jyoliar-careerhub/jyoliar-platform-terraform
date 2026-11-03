terraform {
  required_providers {
    discord = {
      source  = "Lucky3028/discord"
      version = "2.5.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "6.27.0"
    }
  }
}

provider "discord" {
  token = var.discord_bot_token
}

provider "aws" {
  default_tags {
    tags = {
      env = var.env
    }
  }

  region = var.region
}
