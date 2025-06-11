
variable "handler" {
  description = "Function entrypoint in your code"
}

variable "python_version" {
  description = "The runtime version"
}

variable "env_vars" {
  type        = map(string)
  default     = {}
}

variable "role_arn" {
}

variable "memory_size" {
}

variable "timeout" {
}

variable "log_retention" {
  default = 14
}

variable "create_layer" {
  description = "Boolean to create a layer"
  default     = false
}

variable "architectures" {
  description = "List of Lambda architectures"
  type        = list(string)
  default     = ["x86_64"]
}

variable "maximum_retry_attempts" {
  description = "Maximum number of times to retry when the function returns an error. Valid values between 0 and 2. Defaults to 2."
  type        = number
  default     = 1
}

variable "allowed_triggers" {
  description = "Map of allowed triggers to create Lambda permissions"
  type        = map(any)
  default     = {}
}

variable "awslogs_group_name" {
  default = ""
}

variable "retention_in_days" {

}


# Define the name of the Lambda function
variable "lambda_function_name" {
  description = "The name of the Lambda function to be scheduled."
  type        = string
}


# Define the cron schedule for the EventBridge rule
variable "schedule_expression" {
  description = "Cron expression for scheduling the Lambda execution. Default is to run daily at 12:00 PM UTC."
  type        = string
}

# Define a description for the EventBridge rule
variable "schedule_description" {
  description = "Description of the EventBridge rule for Lambda scheduling."
  type        = string
  default     = "Schedule for invoking Lambda function."
}
