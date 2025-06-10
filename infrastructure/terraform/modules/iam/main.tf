resource "aws_iam_role" "ingestor" {
  name = "ingestor-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_arn
        }
        Condition = {
          StringEquals = {
            "${replace(var.oidc_arn, "arn:aws:iam::", "")}:sub" = "system:serviceaccount:ingestion:ingestor"
          }
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "ingestor-role"
    }
  )
}

resource "aws_iam_role_policy" "ingestor" {
  name = "ingestor-policy"
  role = aws_iam_role.ingestor.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::${var.docs_bucket_name}",
          "arn:aws:s3:::${var.docs_bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "chat_api" {
  name = "chat-api-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_arn
        }
        Condition = {
          StringEquals = {
            "${replace(var.oidc_arn, "arn:aws:iam::", "")}:sub" = "system:serviceaccount:api:chat-api"
          }
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "chat-api-role"
    }
  )
}

resource "aws_iam_role_policy" "chat_api" {
  name = "chat-api-policy"
  role = aws_iam_role.chat_api.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::${var.docs_bucket_name}",
          "arn:aws:s3:::${var.docs_bucket_name}/*"
        ]
      }
    ]
  })
} 