module "api_integrations" {
  for_each = local.lambdas

  source = "../_modules/api-gateway-integration"

  identifier  = var.identifier
  environment = var.environment
  suffix      = var.suffix

  sns_topic_arn         = aws_sns_topic.this.arn
  request_validator_map = local.request_validator_map
  api_gateway_id        = aws_api_gateway_rest_api.this.id

  lambda_name                              = each.value.lambda.name
  lambda_description                       = each.value.lambda.description
  lambda_path                              = each.value.lambda.path
  lambda_source_code_bucket                = aws_s3_bucket.lambdas_source_code.bucket
  lambda_runtime                           = lookup(each.value.lambda, "runtime", "python3.11")
  lambda_timeout                           = lookup(each.value.lambda, "timeout", 10)
  lambda_handler                           = lookup(each.value.lambda, "handler", "main.lambda_handler")
  lambda_architectures                     = lookup(each.value.lambda, "architectures", ["arm64"])
  lambda_memory_size                       = lookup(each.value.lambda, "memory_size", 128)
  lambda_ephemeral_storage_size            = lookup(each.value.lambda, "ephemeral_storage_size", 512)
  lambda_layers                            = lookup(each.value.lambda, "layers", local.lambdas_layers)
  lambda_cloudwatch_logs_retention_in_days = lookup(each.value.lambda, "cloudwatch_logs_retention_in_days", 7)
  lambda_attach_policy                     = lookup(each.value.lambda, "attach_policy", false)
  lambda_policy_json                       = lookup(each.value.lambda, "policy_json", {})
  lambda_environment_variables             = lookup(each.value.lambda, "environment_variables", {})

  integration_http_method        = each.value.integration.http_method
  integration_full_path          = each.value.integration.full_path
  integration_resource_id        = each.value.integration.resource_id
  integration_request_validator  = each.value.integration.request_validator
  integration_request_model      = lookup(each.value.integration, "request_model", {})
  integration_request_parameters = lookup(each.value.integration, "request_parameters", {})

  aliases = each.value.aliases
}
