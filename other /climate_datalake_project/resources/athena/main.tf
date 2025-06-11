# Athena

resource "aws_athena_database" "this" {
  name = "jungfrau_athena_db"
  bucket = var.bucket_athena_query_results_id

  encryption_configuration {
    encryption_option = "SSE_S3"
  }
}

resource "aws_athena_workgroup" "this" {
  name = "jungfrau_workgroup"

  configuration {
    result_configuration {
      output_location = "s3://${var.bucket_athena_query_results_id}/workgroup-output/"

      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
    engine_version {
      selected_engine_version  = var.selected_engine_version
    }
  }
  tags = var.common_tags
}
