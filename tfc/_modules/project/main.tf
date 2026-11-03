# 프로젝트 하나 — 프로젝트(tfe_project)와 그 프로젝트가 소유한 variable set · 변수.
# set 은 워크스페이스가 아니라 프로젝트의 것이다 — 소유(parent_project_id)하고, 붙인다(tfe_project_variable_set).
# 소유만으로는 적용되지 않아 붙이는 자원이 따로 있다.

locals {
  # "set/key" → 변수 하나 — tfe_variable 의 for_each 키
  variables = merge([
    for set_name, s in var.variable_sets : {
      for key, v in s.variables : "${set_name}/${key}" => merge(v, { set_name = set_name, key = key })
    }
  ]...)
}

resource "tfe_project" "this" {
  name = var.name

  # prevent_destroy: destroy · replace 가 든 plan 을 plan 단계에서 멈춘다 — 프로젝트는 워크스페이스와 set 을 담는다.
  # 정말 떼어낼 때는 removed 블록(lifecycle { destroy = false })으로 관리만 끊는다.
  lifecycle {
    prevent_destroy = true
  }
}

resource "tfe_variable_set" "this" {
  for_each = var.variable_sets

  name              = each.key
  description       = each.value.description
  parent_project_id = tfe_project.this.id
  priority          = each.value.priority
  global            = false
}

resource "tfe_project_variable_set" "this" {
  for_each = var.variable_sets

  project_id      = tfe_project.this.id
  variable_set_id = tfe_variable_set.this[each.key].id
}

resource "tfe_variable" "this" {
  for_each = local.variables

  variable_set_id = tfe_variable_set.this[each.value.set_name].id
  key             = each.value.key
  value           = each.value.value
  category        = each.value.category
  hcl             = each.value.hcl
  sensitive       = false
}
