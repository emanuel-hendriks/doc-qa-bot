data "aws_caller_identity" "current" {
}

data "template_file" "this" {
  template = file("${path.module}/policy.json")

  vars = { 
    region_prefix              = var.region_prefix
    account_id                 = data.aws_caller_identity.current.account_id
    raw_data_bucket_arn        = var.raw_data_bucket_arn
  }
}

resource "aws_iam_policy" "this" {
  name   = "${var.lambda_name}-policy"
  policy = data.template_file.this.rendered
}
