variable "domain_name" {
  description = "The domain name for the certificate"
  type        = string
}

variable "route53_zone_id" {
  description = "The ID of the Route53 hosted zone for DNS validation"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
