output "id" {
  description = "프로젝트 id — 워크스페이스의 project_id 에 쓴다"
  value       = tfe_project.this.id
}

output "variable_set_ids" {
  description = "set 이름 → variable set id"
  value       = { for k, s in tfe_variable_set.this : k => s.id }
}
