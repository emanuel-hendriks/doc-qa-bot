output "repository_urls" {
  description = "The URLs of the repositories"
  value       = { for k, v in aws_ecr_repository.this : k => v.repository_url }
}

output "repository_arns" {
  description = "The ARNs of the repositories"
  value       = { for k, v in aws_ecr_repository.this : k => v.arn }
}

output "repository_names" {
  description = "The names of the repositories"
  value       = { for k, v in aws_ecr_repository.this : k => v.name }
}
