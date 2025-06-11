variable "owner" {
  description = "Owner to be associated with this resource"
  default = ""
}

variable "environment" {
  description = "The environment of working"
  default = ""
}

variable "identifier" {
  description = "Identifier that describe this resource"
  default = ""
}

variable "awslogs_group_name" {
  description = "The name of the log group"
  default = ""
}

variable "retention_in_days" {
  description = "Log retention in days"
  default = 14
}

variable "common_tags" {
  description = "Common tags among whole infrastructure"
  type        = map(string)
}

variable "enable_infrequent_access" {
  default = true
}