resource "aws_cloudwatch_log_group" "this" {
  for_each = var.log_groups

  name              = each.value.name
  retention_in_days = each.value.retention_in_days

  tags = merge(
    var.tags,
    {
      Name = "${var.project}-${each.key}-logs"
    }
  )
}
