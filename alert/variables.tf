variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "discord_bot_token" {
  type      = string
  sensitive = true
}

variable "discord_server_id" {
  type = string
}
