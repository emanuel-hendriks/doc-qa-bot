output "arn" {
  description = "The arn for the log group."
  value       = aws_cloudwatch_log_group.this.arn
}

output "id" {
  description = "The id for the log group."
  value       = aws_cloudwatch_log_group.this.id
}

output "aws_cloudwatch_log_group" {
  value = aws_cloudwatch_log_group.this
}
