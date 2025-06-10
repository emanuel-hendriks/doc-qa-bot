variable "docs_bucket_name" {
  description = "The name of the S3 bucket for documents"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
} 