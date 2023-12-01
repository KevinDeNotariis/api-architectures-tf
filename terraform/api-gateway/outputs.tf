output "api_gateway_domain_name" {
  value = aws_api_gateway_domain_name.this.domain_name
}

output "api_gateway_api_id" {
  value = aws_api_gateway_rest_api.this.id
}

output "api_gateway_domain_certificate_arn" {
  value = aws_acm_certificate.this.arn
}

output "sns_topic_arn" {
  value = aws_sns_topic.this.arn
}

output "api_lambdas_integration" {
  value = local.lambdas
}
