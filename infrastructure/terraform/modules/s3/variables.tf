variable "bucket_name" {
  description = "Name of the S3 bucket for storing documentation"
  type        = string
}

variable "environment" {
  description = "Environment (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "docs_bucket_name" {
  description = "Name of the S3 bucket for documents"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
} 