output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.docs.id
}

output "bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = aws_s3_bucket.docs.arn
}

output "docs_bucket_name" {
  description = "The name of the S3 bucket for documents"
  value       = aws_s3_bucket.docs.id
}

output "docs_bucket_arn" {
  description = "The ARN of the S3 bucket for documents"
  value       = aws_s3_bucket.docs.arn
} 