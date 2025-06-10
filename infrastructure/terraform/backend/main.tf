provider "aws" {
  region = "eu-south-1"
}

resource "aws_s3_bucket" "tf_state" {
  bucket = "syllotip-demo-tfstate-${random_id.suffix.hex}"
  force_destroy = true
  tags = {
    Name = "syllotip-demo-tfstate"
    Environment = "dev"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_dynamodb_table" "tf_lock" {
  name         = "syllotip-demo-tflock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "syllotip-demo-tflock"
    Environment = "dev"
  }
}
