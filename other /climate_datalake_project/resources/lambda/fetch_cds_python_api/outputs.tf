output "function_arn" {
  description = "Arn of Lambda."
  value       = aws_lambda_function.this.arn
}

output "function_id" {
  description = "Id of the Lambda."
  value       = aws_lambda_function.this.id
}

output "function_name" {
  description = "Name of Lambda."
  value       = aws_lambda_function.this.function_name
}

output "invoke_arn" {
  description = "Invoke Arn Lambda."
  value       = aws_lambda_function.this.invoke_arn
}

