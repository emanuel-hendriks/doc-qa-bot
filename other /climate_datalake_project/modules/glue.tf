
# # IAM 

# module "glue_iam_role" {
#   source      = "./modules/iam_role"
#   role_name   = "glue-role"
#   policies    = [
#     module.raw_data_s3.bucket_policy_arn,
#     module.transformed_data_s3.bucket_policy_arn
#   ]
# }
