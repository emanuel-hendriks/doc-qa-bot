# S3 access policy for Ingestor
resource "aws_iam_policy" "ingestor_s3_access" {
  name        = "ingestor-s3-access"
  description = "Policy for Ingestor to access S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.docs_bucket_name}",
          "arn:aws:s3:::${var.docs_bucket_name}/*"
        ]
      }
    ]
  })
}

# Bedrock access policy
resource "aws_iam_policy" "bedrock_access" {
  name        = "bedrock-access"
  description = "Policy for accessing Bedrock models"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel"
        ]
        Resource = [
          "arn:aws:bedrock:*::foundation-model/*"
        ]
      }
    ]
  })
}

# Secrets Manager access policy
resource "aws_iam_policy" "secrets_access" {
  name        = "secrets-access"
  description = "Policy for accessing Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          var.rds_secret_arn
        ]
      }
    ]
  })
}

# RDS access policy
resource "aws_iam_policy" "rds_access" {
  name        = "rds-access"
  description = "Policy for accessing RDS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds-db:connect"
        ]
        Resource = [
          "arn:aws:rds-db:${var.aws_region}:${var.aws_account_id}:dbuser:${var.rds_resource_id}/*"
        ]
      }
    ]
  })
}
