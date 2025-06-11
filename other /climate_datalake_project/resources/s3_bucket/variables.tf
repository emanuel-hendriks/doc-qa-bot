# Define input variables for the S3 bucket module

variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket"
}

variable "versioning_status" {
  type        = string
  description = "Versioning state of the bucket (Enabled or Suspended)"
  default     = "Enabled"
}

variable "enable_mfa_delete" {
  type        = string
  description = "Enable MFA delete for the bucket (Enabled or Disabled)"
  default     = "Disabled"
}

variable "sse_algorithm" {
  type        = string
  description = "Server-side encryption algorithm (e.g., AES256)"
  default     = "AES256"
}

variable "logging_target_bucket" {
  type        = string
  description = "The name of the S3 bucket for storing access logs"
  default     = ""
}

variable "logging_target_prefix" {
  type        = string
  description = "Prefix for the access log files in the target S3 bucket"
  default     = "logs/"
}

variable "enable_lifecycle_rule" {
  type        = bool
  description = "Enable lifecycle rule for the bucket"
  default     = false
}

variable "lifecycle_expiration_days" {
  type        = number
  description = "Days after which objects should be deleted"
  default     = 30
}

variable "lifecycle_noncurrent_version_expiration_days" {
  type        = number
  description = "Days after which noncurrent versions should be deleted"
  default     = 30
}

variable "lifecycle_prefix" {
  type        = string
  description = "Prefix for lifecycle rules"
  default     = ""
}

variable "common_tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
