data "aws_caller_identity" "current" {
}

data "archive_file" "lambda_source" {
  type        = "zip"
  source_file = "${path.module}/lambda.py"
  output_path = "${path.module}/lambda.zip"
  output_file_mode  = "0666"
}

resource "aws_lambda_function" "this" {
  function_name = var.lambda_function_name
  handler       = var.handler
  role          = var.role_arn
  runtime       = "python${var.python_version}"
  memory_size   = var.memory_size
  timeout       = var.timeout
  architectures = var.architectures
  filename = data.archive_file.lambda_source.output_path
  depends_on = [module.cw_log_group.arn]

}

module "cw_log_group" {
  source = "../../log_group"

  awslogs_group_name = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = var.log_retention
}



# Schedule Lambda execution using EventBridge (CloudWatch Events)
resource "aws_cloudwatch_event_rule" "lambda_schedule" {
  name        = "${var.lambda_function_name}-schedule"
  description = "Schedule for invoking ${var.lambda_function_name} Lambda function"
  
  # Define the cron expression (runs daily at 12:00 PM UTC)
  schedule_expression = "cron(0 12 * * ? *)"
}

# Permissions for EventBridge to invoke Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule.arn
}

# Target to link EventBridge rule to Lambda function
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.lambda_schedule.name
  target_id = "lambda"
  arn       = aws_lambda_function.this.arn
}