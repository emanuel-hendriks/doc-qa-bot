variable "name" {
  description = "The name of the ALB"
  type        = string
}

variable "internal" {
  description = "If true, the ALB will be internal"
  type        = bool
  default     = false
}

variable "security_group_id" {
  description = "The security group ID for the ALB"
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs to attach to the ALB"
  type        = list(string)
}

variable "vpc_id" {
  description = "The VPC ID where the ALB will be created"
  type        = string
}

variable "enable_deletion_protection" {
  description = "If true, deletion of the load balancer will be disabled via the AWS API"
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "The ARN of the default SSL server certificate"
  type        = string
}

variable "target_group_port" {
  description = "The port on which targets receive traffic"
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "The destination for the health check request"
  type        = string
  default     = "/"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
