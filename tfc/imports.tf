# 선언형 import — 콘솔에 이미 있는 워크스페이스 · 설정 · 변수를 이 state 로 들인다.
# import 가 끝나면(plan 이 "No changes") 이 파일은 지운다.

locals {
  import_workspaces = {
    tfc        = "tfc"
    alert      = "onpremise-alert"
    backup     = "prod-careerhub-backup"
    ci         = "careerhub-ci"
    cloudflare = "platform-cloudflare"
    iam        = "onpremise-iam"
    oauth      = "careerhub-oauth"
    vpc        = "onpremise-vpc"
    vpn        = "onpremise-vpn"
    zitadel    = "prod-careerhub-zitadel"
  }
}

import {
  to = tfe_workspace.tfc
  id = "${local.organization}/${local.import_workspaces.tfc}"
}
import {
  to = tfe_workspace_settings.tfc
  id = "${local.organization}/${local.import_workspaces.tfc}"
}

import {
  to = tfe_workspace.alert
  id = "${local.organization}/${local.import_workspaces.alert}"
}
import {
  to = tfe_workspace_settings.alert
  id = "${local.organization}/${local.import_workspaces.alert}"
}

import {
  to = tfe_workspace.backup
  id = "${local.organization}/${local.import_workspaces.backup}"
}
import {
  to = tfe_workspace_settings.backup
  id = "${local.organization}/${local.import_workspaces.backup}"
}

import {
  to = tfe_workspace.ci
  id = "${local.organization}/${local.import_workspaces.ci}"
}
import {
  to = tfe_workspace_settings.ci
  id = "${local.organization}/${local.import_workspaces.ci}"
}

import {
  to = tfe_workspace.cloudflare
  id = "${local.organization}/${local.import_workspaces.cloudflare}"
}
import {
  to = tfe_workspace_settings.cloudflare
  id = "${local.organization}/${local.import_workspaces.cloudflare}"
}

import {
  to = tfe_workspace.iam
  id = "${local.organization}/${local.import_workspaces.iam}"
}
import {
  to = tfe_workspace_settings.iam
  id = "${local.organization}/${local.import_workspaces.iam}"
}

import {
  to = tfe_workspace.oauth
  id = "${local.organization}/${local.import_workspaces.oauth}"
}
import {
  to = tfe_workspace_settings.oauth
  id = "${local.organization}/${local.import_workspaces.oauth}"
}

import {
  to = tfe_workspace.vpc
  id = "${local.organization}/${local.import_workspaces.vpc}"
}
import {
  to = tfe_workspace_settings.vpc
  id = "${local.organization}/${local.import_workspaces.vpc}"
}

import {
  to = tfe_workspace.vpn
  id = "${local.organization}/${local.import_workspaces.vpn}"
}
import {
  to = tfe_workspace_settings.vpn
  id = "${local.organization}/${local.import_workspaces.vpn}"
}

import {
  to = tfe_workspace.zitadel
  id = "${local.organization}/${local.import_workspaces.zitadel}"
}
import {
  to = tfe_workspace_settings.zitadel
  id = "${local.organization}/${local.import_workspaces.zitadel}"
}

# 변수 — <org>/<workspace name>/<variable id>
import {
  to = tfe_variable.alert_discord_server_id
  id = "${local.organization}/onpremise-alert/var-rYSvtnazpdoUETr4"
}
import {
  to = tfe_variable.cloudflare_account_id
  id = "${local.organization}/platform-cloudflare/var-WWHejaDyPhiSxPhn"
}
import {
  to = tfe_variable.oauth_tfc_gcp_provider_auth
  id = "${local.organization}/careerhub-oauth/var-M9RbwbJKSX5cWabm"
}
import {
  to = tfe_variable.oauth_tfc_gcp_workload_provider_name
  id = "${local.organization}/careerhub-oauth/var-DLhRu3dYwkEfVQTY"
}
import {
  to = tfe_variable.oauth_tfc_gcp_run_service_account_email
  id = "${local.organization}/careerhub-oauth/var-56NgKA2yJehRHL43"
}
import {
  to = tfe_variable.vpn_ssh_public_key
  id = "${local.organization}/onpremise-vpn/var-v2gB73fb882GreJf"
}
import {
  to = tfe_variable.vpn_other_site_cidr_blocks
  id = "${local.organization}/onpremise-vpn/var-9cpWuWfucxnjRUUB"
}
