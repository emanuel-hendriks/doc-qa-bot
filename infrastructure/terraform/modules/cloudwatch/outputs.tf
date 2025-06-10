output "log_group_names" {
  description = "Names of the CloudWatch log groups"
  value       = { for k, v in aws_cloudwatch_log_group.this : k => v.name }
}

output "log_group_arns" {
  description = "ARNs of the CloudWatch log groups"
  value       = { for k, v in aws_cloudwatch_log_group.this : k => v.arn }
}
