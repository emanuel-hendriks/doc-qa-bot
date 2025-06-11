module "era5_raw_data_bucket" {
  source = "../resources/s3_bucket"

  bucket_name                         = "jungfrau-era5-raw-data-storage"
  sse_algorithm                       = "AES256"
  logging_target_bucket               = "log-bucket"
  logging_target_prefix               = "era5-raw-logs/"
  enable_lifecycle_rule               = true
  lifecycle_expiration_days           = 365
  lifecycle_noncurrent_version_expiration_days = 90
  lifecycle_prefix                    = "raw-data/"

  common_tags = {
    Project = "ORD-Hackathon"
    Owner   = "Jungfrau"
  }
}

module "era5_processed_data_bucket" {
  source = "../resources/s3_bucket"

  bucket_name                         = "jungfrau-era5-processed-data-storage"
  sse_algorithm                       = "AES256"
  logging_target_bucket               = "log-bucket"
  logging_target_prefix               = "era5-processed-logs/"
  enable_lifecycle_rule               = true
  lifecycle_expiration_days           = 365  # 
  lifecycle_noncurrent_version_expiration_days = 90  
  lifecycle_prefix                    = "processed-data/" 

  common_tags = {
    Project = "ORD-Hackathon"
    Owner   = "Jungfrau"
  }
}


module "athena_s3_bucket" {

  source = "../resources/s3_bucket"

  bucket_name                         = "athena_bucket"
  sse_algorithm                       = "AES256"
  logging_target_bucket               = "log-bucket"
  logging_target_prefix               = "athena_logs/"
  enable_lifecycle_rule               = true
  lifecycle_expiration_days           = 365
  lifecycle_noncurrent_version_expiration_days = 90
  lifecycle_prefix                    = "data/"

  common_tags = {
    Project = "ORD-Hackathon"
    Owner   = "Jungfrau"
  }
}