# Define the S3 bucket resource
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  # Enable logging if a target bucket is specified
  dynamic "logging" {
    for_each = var.logging_target_bucket != "" ? [var.logging_target_bucket] : []
    content {
      target_bucket = var.logging_target_bucket
      target_prefix = var.logging_target_prefix
    }
  }

  # Apply common tags to the bucket
  tags = var.common_tags
}


resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.bucket_encryption_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_kms_key" "bucket_encryption_key" {
  description = "KMS key for S3 bucket encryption"
  is_enabled  = true

  tags = {
    Name = "bucket-kms-key"
  }
}


# Define S3 bucket versioning configuration
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status     = var.versioning_status  # Enabled or Suspended
    mfa_delete = var.enable_mfa_delete  # Optional: Enabled or Disabled
  }
}

# Define S3 bucket lifecycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "lifecycle-rule"
    status = var.enable_lifecycle_rule ? "Enabled" : "Disabled"

    filter {
      prefix = var.lifecycle_prefix
    }

    # Define expiration for current objects
    expiration {
      days = var.lifecycle_expiration_days
    }

    # Noncurrent object version expiration
    noncurrent_version_expiration {
      noncurrent_days = var.lifecycle_noncurrent_version_expiration_days
    }
  }
}

# Define S3 bucket policy to allow Lambda access (Optional)
resource "aws_s3_bucket_policy" "lambda_access" {
  bucket = aws_s3_bucket.this.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action   = "s3:PutObject",
      Resource = "${aws_s3_bucket.this.arn}/*"
    }]
  })
}
