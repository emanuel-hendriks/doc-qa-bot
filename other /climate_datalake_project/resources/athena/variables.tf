variable "bucket_athena_query_results_id" {
  default = "Destination bucket for query result"
}

variable "output_folder" {
  default = ""
}

variable "selected_engine_version" {
  description = "The requested engine version"
  default = "AUTO"
}

variable "enforce_workgroup_configuration" {
  description = "Boolean whether the settings for the workgroup override client-side settings"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common tags among whole infrastructure"
  type        = map(string)
}