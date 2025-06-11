# Define the name of the Lambda function
variable "lambda_function_name" {
  description = "The name of the Lambda function to be scheduled."
  type        = string
}

# Define the ARN of the Lambda function
variable "lambda_function_arn" {
  description = "The ARN of the Lambda function to be invoked by EventBridge."
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
