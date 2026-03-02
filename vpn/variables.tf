variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "tailscale_auth_key" {
  type      = string
  sensitive = true
}

variable "ssh_public_key" {
  type = string
}

variable "additional_public_key" {
  type    = string
  default = ""
}

variable "other_site_cidr_blocks" {
  type = list(string)
}
