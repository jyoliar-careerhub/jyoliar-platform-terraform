output "id" {
  description = "워크스페이스 id — remote state 소비자 선언에 쓴다"
  value       = tfe_workspace.this.id
}

output "name" {
  value = tfe_workspace.this.name
}
