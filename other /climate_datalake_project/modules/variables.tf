variable "glue_crawler_args_compare" {
  description = "The args to create glue crawlers using count"
  default = [
    {
      crawler_name   = ""
      table_prefix   = ""
      s3_target_path = "path/to/s3"
    }
  ]
}

variable "region_prefix" {
  default = "eu-*"
}

variable "schedule_expression" {
  description = "Cron expression for scheduling the Lambda execution. Default is to run daily at 12:00 PM UTC."
  type        = string
  default     = "cron(0 12 * * ? *)"
}

