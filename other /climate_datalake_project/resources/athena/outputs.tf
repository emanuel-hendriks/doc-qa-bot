output "id" {
  description = "Database ID."
  value       = aws_athena_database.this.id
}

output "workgroup_id" {
  description = "Database ID."
  value       = aws_athena_workgroup.this.id
}
