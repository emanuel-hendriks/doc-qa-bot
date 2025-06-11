locals {
 prefix = "${var.identifier}"
 log_group_name = "${local.prefix}-log-group"
}

resource "aws_cloudwatch_log_group" "this" {
  name = local.log_group_name

  retention_in_days = var.retention_in_days

  lifecycle {
    create_before_destroy = false
  }
}
