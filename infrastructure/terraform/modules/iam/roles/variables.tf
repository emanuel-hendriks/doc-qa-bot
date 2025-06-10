variable "eks_oidc_issuer_url" {
  description = "The OIDC issuer URL for the EKS cluster"
  type        = string
}

variable "ingestor_s3_policy_arn" {
  description = "ARN of the S3 access policy for Ingestor"
  type        = string
}

variable "bedrock_policy_arn" {
  description = "ARN of the Bedrock access policy"
  type        = string
}

variable "secrets_policy_arn" {
  description = "ARN of the Secrets Manager access policy"
  type        = string
}

variable "rds_policy_arn" {
  description = "ARN of the RDS access policy"
  type        = string
}
