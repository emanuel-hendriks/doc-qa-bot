output "certificate_arn" {
  description = "The ARN of the certificate"
  value       = aws_acm_certificate.main.arn
}

output "certificate_domain_validation_options" {
  description = "The domain validation options for the certificate"
  value       = aws_acm_certificate.main.domain_validation_options
}

output "certificate_status" {
  description = "The status of the certificate"
  value       = aws_acm_certificate.main.status
}

output "certificate_validation_arn" {
  description = "The ARN of the certificate validation"
  value       = aws_acm_certificate_validation.main.certificate_arn
}
