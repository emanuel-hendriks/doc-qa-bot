output "ingestor_role_arn" {
  description = "ARN of the Ingestor IAM role"
  value       = aws_iam_role.ingestor.arn
}

output "chat_api_role_arn" {
  description = "ARN of the Chat API IAM role"
  value       = aws_iam_role.chat_api.arn
}

output "oidc_provider_arn" {
  description = "ARN of the EKS OIDC provider"
  value       = aws_iam_openid_connect_provider.eks.arn
}
