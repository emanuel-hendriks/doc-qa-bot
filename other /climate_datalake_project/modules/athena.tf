module "aws_athena_database" {
  source = "../resources/athena" 

  bucket_athena_query_results_id = module.athena_s3_bucket.arn

  common_tags = {}
}
