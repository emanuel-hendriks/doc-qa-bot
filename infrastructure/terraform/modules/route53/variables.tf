variable "domain_name" {
  description = "The domain name for the hosted zone"
  type        = string
}

variable "create_ns_records" {
  description = "Whether to create NS records for the domain"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
} 