output "ingestor_role_arn" {
  description = "The ARN of the ingestor IAM role"
  value       = aws_iam_role.ingestor.arn
}

output "ingestor_role_name" {
  description = "The name of the ingestor IAM role"
  value       = aws_iam_role.ingestor.name
}

output "chat_api_role_arn" {
  description = "The ARN of the chat API IAM role"
  value       = aws_iam_role.chat_api.arn
}

output "chat_api_role_name" {
  description = "The name of the chat API IAM role"
  value       = aws_iam_role.chat_api.name
} 