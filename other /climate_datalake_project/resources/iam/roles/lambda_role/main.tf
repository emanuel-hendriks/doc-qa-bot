locals {
 prefix = var.lambda_name
}

resource "aws_iam_role" "this" {
  name               = "${local.prefix}-role"
  assume_role_policy = file("${path.module}/trust_relationships.json")

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "custom" {
  count = length(var.arn_custom_policy)

  role       = aws_iam_role.this.name
  policy_arn = var.arn_custom_policy[count.index]
}

resource "aws_iam_role_policy" "this" {
  count     = length(var.inline_policy)
  
  name       = "${local.prefix}-inline-policy-${count.index+1}"
  role       = aws_iam_role.this.name
  policy     = var.inline_policy[count.index].json
}