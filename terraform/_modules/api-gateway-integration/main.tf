# ------------------------------------------------------------------------------------------
# Api Gateway Model
# ------------------------------------------------------------------------------------------
resource "aws_api_gateway_model" "this" {
  count = var.integration_request_model == {} ? 0 : 1

  rest_api_id  = var.api_gateway_id
  name         = var.integration_request_model.name
  description  = var.integration_request_model.description
  content_type = var.integration_request_model.content_type
  schema       = var.integration_request_model.schema
}

# ------------------------------------------------------------------------------------------
# Api Gateway Method and integration
# ------------------------------------------------------------------------------------------
resource "aws_api_gateway_method" "this" {
  rest_api_id          = var.api_gateway_id
  resource_id          = var.integration_resource_id
  http_method          = var.integration_http_method
  api_key_required     = true
  authorization        = "NONE"
  request_models       = var.integration_request_model == {} ? {} : { "${var.integration_request_model.content_type}" = "${aws_api_gateway_model.this[0].name}" }
  request_validator_id = var.request_validator_map[var.integration_request_validator]
  request_parameters = merge(
    var.integration_request_parameters,
    {
      "method.request.header.Content-Type" = true
    }
  )

  depends_on = [
    aws_api_gateway_model.this
  ]
}

resource "aws_api_gateway_integration" "this" {
  rest_api_id             = var.api_gateway_id
  resource_id             = aws_api_gateway_method.this.resource_id
  http_method             = aws_api_gateway_method.this.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${module.lambda_integration.lambda_function_arn}:$${stageVariables.environment}/invocations"
}

# ------------------------------------------------------------------------------------------
# Lambda function
# ------------------------------------------------------------------------------------------
module "lambda_integration" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "6.0.0"

  function_name          = "${local.identifier}-${var.lambda_name}-${var.suffix}"
  hash_extra             = "${local.identifier}-${var.lambda_name}-${var.suffix}"
  description            = var.lambda_description
  handler                = var.lambda_handler
  runtime                = var.lambda_runtime
  architectures          = var.lambda_architectures
  memory_size            = var.lambda_memory_size
  ephemeral_storage_size = var.lambda_ephemeral_storage_size
  timeout                = var.lambda_timeout
  publish                = true
  source_path            = coalesce(var.lambda_path, "${path.root}/lambdas/${var.lambda_name}")
  layers                 = var.lambda_layers

  cloudwatch_logs_retention_in_days = var.lambda_cloudwatch_logs_retention_in_days

  store_on_s3 = true
  s3_bucket   = var.lambda_source_code_bucket

  environment_variables = var.lambda_environment_variables

  attach_policy_json    = var.lambda_attach_policy
  policy_json           = var.lambda_policy_json
  attach_tracing_policy = true
}

# ------------------------------------------------------------------------------------------
# Lambda Aliases and permissions
# ------------------------------------------------------------------------------------------
resource "aws_lambda_alias" "lambda_integration" {
  for_each = var.aliases

  name             = each.key
  function_name    = module.lambda_integration.lambda_function_name
  function_version = each.value
}

resource "aws_lambda_permission" "lambda_integration" {
  for_each = var.aliases

  statement_id_prefix = "ApiGateway${title(each.key)}"
  action              = "lambda:InvokeFunction"
  function_name       = module.lambda_integration.lambda_function_name
  principal           = "apigateway.amazonaws.com"
  qualifier           = each.key

  source_arn = format("arn:aws:execute-api:%s:%s:%s/%s/%s/%s",
    data.aws_region.current.name,
    data.aws_caller_identity.current.account_id,
    var.api_gateway_id,
    each.key,
    upper(var.integration_http_method),
    var.integration_full_path,
  )

  depends_on = [
    aws_lambda_alias.lambda_integration
  ]
}

# ------------------------------------------------------------------------------------------
# Api Gateway Documentation
# ------------------------------------------------------------------------------------------
resource "aws_api_gateway_documentation_part" "this" {
  location {
    type   = "METHOD"
    method = var.integration_http_method
    path   = "/${var.integration_full_path}"
  }

  properties = jsonencode({
    description = var.lambda_description
  })
  rest_api_id = var.api_gateway_id
}
