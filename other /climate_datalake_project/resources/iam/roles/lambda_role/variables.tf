variable "lambda_name" {
}

variable "arn_custom_policy" {
  default = []
  description = "The ARN of the custom policy"
}

variable "inline_policy" {
  default     = []
  description = "Inline policy"
}

variable "common_tags" {
  description = "Common tags among whole infrastructure"
  type        = map(string)
}
