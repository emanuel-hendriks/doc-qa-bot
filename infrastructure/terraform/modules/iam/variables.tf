variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "oidc_arn" {
  description = "The ARN of the OIDC provider"
  type        = string
}

variable "docs_bucket_name" {
  description = "The name of the S3 bucket for documents"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
} 