variable "docs_bucket_name" {
  description = "Name of the S3 bucket containing documents"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "rds_resource_id" {
  description = "RDS resource ID"
  type        = string
}

variable "rds_secret_arn" {
  description = "ARN of the RDS credentials secret in Secrets Manager"
  type        = string
}
