
// create lambda function and log group  

module "lambda_fetch_data_cds_api" {
  source = "../resources/lambda/fetch_cds_python_api"
  
  lambda_function_name =  "fetch_data_cds"
  schedule_expression =  ""

  handler = "lambda.handler"
  retention_in_days = 14

  role_arn = ""
  python_version = 3.12
  memory_size    = 512
  timeout        = 300
}


module "lambda_scheduler" {
  source = "../resources/event_bridge"

  lambda_function_name = module.lambda_fetch_data_cds_api.function_name
  lambda_function_arn  = module.lambda_fetch_data_cds_api.function_arn
  schedule_expression  = var.schedule_expression  
  schedule_description = ""
}


# IAM 

module "role_lambda_common" {
  source = "../resources/iam/roles/lambda_role"

lambda_name = module.lambda_fetch_data_cds_api.function_name
  arn_custom_policy = [
    module.policy_lambda_common.arn
  ]
  common_tags = {}
}

module "policy_lambda_common" {
  source = "../resources/iam/policies/lambda_policy"
  lambda_name = module.lambda_fetch_data_cds_api.function_name
  region_prefix = "eu-*"
  raw_data_bucket_arn = module.era5_raw_data_bucket.arn
}

