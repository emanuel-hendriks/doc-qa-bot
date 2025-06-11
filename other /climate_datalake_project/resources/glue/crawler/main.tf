# resource "aws_glue_crawler" "this" {

#   name          = var.crawler_name
#   database_name = var.glue_crawler_database_name
#   role          = var.glue_crawler_role

#   description            = var.description
#   classifiers            = var.glue_crawler_classifiers
#   configuration          = var.glue_crawler_configuration
#   schedule               = var.glue_crawler_schedule
#   security_configuration = var.glue_crawler_security_configuration
#   table_prefix           = var.glue_crawler_table_prefix


#   dynamic "s3_target" {
#     for_each = var.glue_crawler_s3_target

#     content {
#       path       = s3_target.value.path
#       exclusions = try(flatten(s3_target.value.exclusions), [])
#     }
#   }

#   dynamic "schema_change_policy" {
#     iterator = schema_change_policy
#     for_each = var.glue_crawler_schema_change_policy

#     content {
#       delete_behavior = lookup(schema_change_policy.value, "delete_behavior", null)
#       update_behavior = lookup(schema_change_policy.value, "update_behavior", null)
#     }
#   }

#   dynamic "lineage_configuration" {
#     iterator = lineage_configuration
#     for_each = var.glue_crawler_lineage_configuration

#     content {
#       crawler_lineage_settings = lookup(lineage_configuration.value, "crawler_lineage_settings", null)
#     }
#   }

#   dynamic "recrawl_policy" {
#     iterator = recrawl_policy
#     for_each = var.glue_crawler_recrawl_policy

#     content {
#       recrawl_behavior = lookup(recrawl_policy.value, "recrawl_behavior", null)
#     }
#   }


#   lifecycle {
#     create_before_destroy = true
#     ignore_changes        = []
#   }
# }


# resource "aws_glue_crawler" "raw_data_crawler" {
#   name              = "raw-data-crawler"
#   role              = aws_iam_role.glue_role.arn  # Glue role with required permissions
#   database_name     = aws_glue_catalog_database.your_database.name
#   s3_target {
#     path = "s3://${aws_s3_bucket.raw_data_bucket.bucket}/raw-data/"
#   }
#   # Optional configuration for file format (JSON, CSV, Parquet, etc.)
#   configuration = jsonencode({
#     "Version" : 1.0,
#     "CrawlerOutput" : {
#       "Partitions" : {
#         "AddPartitionIndex" : false
#       }
#     }
#   })
# }



# IAM Role for Glue
resource "aws_iam_role" "glue_execution_role" {
  name = "glue-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "glue.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach policies to the role for S3 access
resource "aws_iam_policy_attachment" "glue_s3_access" {
  name       = "glue-s3-access"
  roles      = [aws_iam_role.glue_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Glue Job for NetCDF to Parquet conversion
resource "aws_glue_job" "netcdf_to_parquet" {
  name     = "convert_netcdf_to_parquet"
  role_arn = aws_iam_role.glue_execution_role.arn

  # Glue job command pointing to the PySpark script in S3
  command {
    name            = "glueetl"
    script_location = "s3://${module.glue_script_bucket.bucket_name}/${aws_s3_bucket_object.netcdf_to_parquet_script.key}"
    python_version  = "3"  # Glue's Python version for PySpark
  }

  # Arguments passed to the PySpark script
  default_arguments = {
    "--enable-metrics"                   = "true"
    "--job-bookmark-option"              = "job-bookmark-enable"
    "--S3_INPUT_BUCKET"                  = module.era5_raw_data_bucket.bucket_name
    "--S3_OUTPUT_BUCKET"                 = module.era5_processed_data_bucket.bucket_name
    "--timestamp_filter"                 = "2022-01-01 2022-01-31"
    "--resolution"                       = 10
    "--file_name"                        = "precipitation_amount_1hour_Accumulation.nc"
    "--TempDir"                          = "s3://${module.glue_script_bucket.bucket_name}/temp/"
    "--enable-glue-datacatalog"          = ""
  }

  # Define the maximum retries and timeout for the Glue job
  max_retries = 2
  timeout     = 2880  # 48 hours
}


# Upload PySpark script to S3

resource "aws_s3_bucket_object" "netcdf_to_parquet_script" {
  bucket = module.glue_script_bucket.bucket_name
  key    = "netcdf_to_parquet.py"
  source = "${path.module}/scripts/netcdf_to_parquet.py"  # Path to local script

  # Content type is Python code
  content_type = "text/x-python"
}