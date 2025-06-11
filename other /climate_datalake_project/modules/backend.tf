resource "aws_s3_bucket" "climate_datalake" {
    bucket = "jungfrau-climate-datalake-backend-bucket"
}

resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name = "climate-datalake-tfstate-locking"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20
 
  attribute {
    name = "LockID"
    type = "S"
  }
}
