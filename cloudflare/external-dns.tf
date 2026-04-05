data "cloudflare_account_api_token_permission_groups_list" "all" {
  account_id = var.cloudflare_account_id
}

locals {
  _zone_pg_map = {
    for pg in data.cloudflare_account_api_token_permission_groups_list.all.result :
    pg.name => pg.id
    if contains(pg.scopes, "com.cloudflare.api.account.zone")
  }
}

resource "cloudflare_api_token" "external_dns" {
  name = "k8s-external-dns"

  policies = [{
    effect = "allow"
    permission_groups = [
      { id = local._zone_pg_map["Zone Read"] },
      { id = local._zone_pg_map["DNS Write"] },
    ]
    resources = jsonencode({
      "com.cloudflare.api.account.zone.${cloudflare_zone.this.id}" = "*"
    })
  }]
}

resource "aws_ssm_parameter" "external_dns_cloudflare_token" {
  provider = aws.ssm

  name  = "/jyo-liar/k8s/baremetal/external-dns/cloudflare-api-token"
  type  = "SecureString"
  value = cloudflare_api_token.external_dns.value
}
