output "arn" {
  description = "The arn of the role for job batch."
  value       = aws_iam_role.this.arn
}

output "name" {
  description = "The name of the role for job batch."
  value       = aws_iam_role.this.name
}