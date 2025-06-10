output "ingestor_s3_policy_arn" {
  description = "ARN of the S3 access policy for Ingestor"
  value       = aws_iam_policy.ingestor_s3_access.arn
}

output "bedrock_policy_arn" {
  description = "ARN of the Bedrock access policy"
  value       = aws_iam_policy.bedrock_access.arn
}

output "secrets_policy_arn" {
  description = "ARN of the Secrets Manager access policy"
  value       = aws_iam_policy.secrets_access.arn
}

output "rds_policy_arn" {
  description = "ARN of the RDS access policy"
  value       = aws_iam_policy.rds_access.arn
}
