resource "cloudflare_zone" "this" {
  account = {
    id = var.cloudflare_account_id
  }
  name = var.domain
  type = "full"
}

resource "aws_route53domains_registered_domain" "this" {
  domain_name = var.domain

  dynamic "name_server" {
    for_each = cloudflare_zone.this.name_servers
    content {
      name = name_server.value
    }
  }
}
