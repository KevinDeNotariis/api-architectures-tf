locals {
  identifier = "${var.identifier}-${var.environment}"

  api_gateway_stages = ["test", "prod"]
  api_gateway_alias  = "${var.api_gateway_subdomain}.${var.root_domain}"

  request_validator_map = {
    "body-only"   = aws_api_gateway_request_validator.body_only.id
    "params-only" = aws_api_gateway_request_validator.params_only.id
    "all"         = aws_api_gateway_request_validator.all.id
    "none"        = aws_api_gateway_request_validator.none.id
  }

  lambdas_folder_path = "${path.module}/../_lambdas"

  lambdas_layers = [
    "arn:aws:lambda:${data.aws_region.current.name}:017000801446:layer:AWSLambdaPowertoolsPythonV2-Arm64:51"
  ]
}
