resource "aws_cloudwatch_log_group" "this" {
  name = var.awslogs_group_name
  retention_in_days = 14
}
