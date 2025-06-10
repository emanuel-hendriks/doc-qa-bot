output "docs_bucket_id" {
  description = "The name of the bucket"
  value       = aws_s3_bucket.docs.id
}

output "docs_bucket_arn" {
  description = "The ARN of the bucket"
  value       = aws_s3_bucket.docs.arn
}

output "docs_bucket_domain_name" {
  description = "The bucket domain name"
  value       = aws_s3_bucket.docs.bucket_domain_name
} 