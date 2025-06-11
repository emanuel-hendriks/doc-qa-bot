# # Define S3 bucket where data is uploaded
# resource "aws_s3_bucket" "data_storage_bucket" {
#   bucket = "your-data-bucket"
# }

# # Lambda function to be triggered by the S3 event
# resource "aws_lambda_function" "trigger_glue" {
#   function_name = "trigger-glue-job"
#   runtime       = "python3.12"
#   handler       = "lambda_function.lambda_handler"
#   role          = aws_iam_role.lambda_exec_role.arn
#   filename      = "trigger_glue_lambda.zip"  # Zip file with Lambda code
# }

# # Allow S3 to invoke the Lambda function
# resource "aws_lambda_permission" "allow_s3_invoke" {
#   statement_id  = "AllowS3InvokeLambda"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.trigger_glue.function_name
#   principal     = "s3.amazonaws.com"
#   source_arn    = aws_s3_bucket.data_storage_bucket.arn
# }

# # Define the S3 event notification for PUT object to trigger Lambda
# resource "aws_s3_bucket_notification" "s3_event_trigger" {
#   bucket = aws_s3_bucket.data_storage_bucket.id

#   lambda_function {
#     lambda_function_arn = aws_lambda_function.trigger_glue.arn
#     events              = ["s3:ObjectCreated:*"]
#   }
# }
