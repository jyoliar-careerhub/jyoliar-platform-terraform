terraform {
  required_providers {
    discord = {
      source  = "Lucky3028/discord"
      version = "2.5.0"
    }
  }
}

provider "discord" {
  token = var.discord_bot_token
}
