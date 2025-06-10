# OIDC provider for EKS
data "tls_certificate" "eks" {
  url = var.eks_oidc_issuer_url
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = var.eks_oidc_issuer_url
}

# Ingestor role
resource "aws_iam_role" "ingestor" {
  name = "ingestor-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.eks_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:ingestion:ingestor-sa"
          }
        }
      }
    ]
  })
}

# Chat API role
resource "aws_iam_role" "chat_api" {
  name = "chat-api-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.eks_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:api:chat-sa"
          }
        }
      }
    ]
  })
}

# Attach policies to Ingestor role
resource "aws_iam_role_policy_attachment" "ingestor_s3" {
  role       = aws_iam_role.ingestor.name
  policy_arn = var.ingestor_s3_policy_arn
}

resource "aws_iam_role_policy_attachment" "ingestor_bedrock" {
  role       = aws_iam_role.ingestor.name
  policy_arn = var.bedrock_policy_arn
}

resource "aws_iam_role_policy_attachment" "ingestor_secrets" {
  role       = aws_iam_role.ingestor.name
  policy_arn = var.secrets_policy_arn
}

resource "aws_iam_role_policy_attachment" "ingestor_rds" {
  role       = aws_iam_role.ingestor.name
  policy_arn = var.rds_policy_arn
}

# Attach policies to Chat API role
resource "aws_iam_role_policy_attachment" "chat_bedrock" {
  role       = aws_iam_role.chat_api.name
  policy_arn = var.bedrock_policy_arn
}

resource "aws_iam_role_policy_attachment" "chat_secrets" {
  role       = aws_iam_role.chat_api.name
  policy_arn = var.secrets_policy_arn
}

resource "aws_iam_role_policy_attachment" "chat_rds" {
  role       = aws_iam_role.chat_api.name
  policy_arn = var.rds_policy_arn
}
