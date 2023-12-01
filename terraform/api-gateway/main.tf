# ------------------------------------------------------------------------------------------
# Api Gateway
# ------------------------------------------------------------------------------------------
resource "aws_api_gateway_rest_api" "this" {
  name = "${var.identifier}-${var.environment}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  put_rest_api_mode = "merge"
}

# ------------------------------------------------------------------------------------------
# IAM for API gateway to push cloudwatch logs
# ------------------------------------------------------------------------------------------
data "aws_iam_policy_document" "api_gateway_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "api_gateway" {
  name               = "${var.identifier}-api-gateway-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.api_gateway_assume.json
}

resource "aws_iam_role_policy_attachment" "api_gateway" {
  role       = aws_iam_role.api_gateway.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_api_gateway_account" "this" {
  cloudwatch_role_arn = aws_iam_role.api_gateway.arn
}

# ------------------------------------------------------------------------------------------
# Api gateway Custom Responses
# ------------------------------------------------------------------------------------------
resource "aws_api_gateway_gateway_response" "access_denied_403" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  status_code   = "403"
  response_type = "ACCESS_DENIED"

  response_templates = {
    "application/json" = "{\"errorCode\":\"$context.authorizer.errorCode\", \"errorType\": \"$context.authorizer.errorType\", \"errorMessage\": \"$context.authorizer.errorMessage\"}"
  }
}

resource "aws_api_gateway_gateway_response" "bad_request_body_400" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  status_code   = "400"
  response_type = "BAD_REQUEST_BODY"

  response_templates = {
    "application/json" = "{\n \"message\": \"Invalid request body\", \n \"cause\": \"$context.error.validationErrorString\" \n }"
  }
}

# ------------------------------------------------------------------------------------------
# Api gateway Stage and Deployment
# ------------------------------------------------------------------------------------------
resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  description = "Deployment of API for: ${local.identifier}-${var.suffix}"

  triggers = {
    redeployment = sha256(jsonencode(flatten([
      module.api_integrations[*],
      aws_api_gateway_resource.string,
      aws_api_gateway_resource.string_replace,
      aws_api_gateway_gateway_response.access_denied_403,
      aws_api_gateway_gateway_response.bad_request_body_400,
    ])))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "api_gateway_stage" {
  for_each          = toset(var.api_gateway_stages)
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.this.id}/${each.key}"
  retention_in_days = var.api_gateway_stage_logs_retention_id_days
}

resource "aws_api_gateway_stage" "this" {
  for_each = toset(var.api_gateway_stages)

  rest_api_id          = aws_api_gateway_rest_api.this.id
  deployment_id        = aws_api_gateway_deployment.this.id
  stage_name           = each.key
  description          = "${title(each.key)} stage"
  xray_tracing_enabled = true

  variables = {
    environment = each.key
  }

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_stage[each.key].arn
    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      authorizer              = "$context.authorizer.error"
    })
  }
}

# ------------------------------------------------------------------------------------------
# Api gateway Custom Domain Name
# ------------------------------------------------------------------------------------------
resource "aws_acm_certificate" "this" {
  domain_name       = local.api_gateway_alias
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  allow_overwrite = true
  name            = tolist(aws_acm_certificate.this.domain_validation_options)[0].resource_record_name
  records         = [tolist(aws_acm_certificate.this.domain_validation_options)[0].resource_record_value]
  type            = tolist(aws_acm_certificate.this.domain_validation_options)[0].resource_record_type
  zone_id         = var.public_hosted_zone_id
  ttl             = 60
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}

resource "aws_api_gateway_domain_name" "this" {
  regional_certificate_arn = aws_acm_certificate_validation.this.certificate_arn
  domain_name              = local.api_gateway_alias
  security_policy          = "TLS_1_2"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_route53_record" "this" {
  zone_id = var.public_hosted_zone_id
  name    = local.api_gateway_alias
  type    = "A"

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.this.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.this.regional_zone_id
  }
}

resource "aws_api_gateway_base_path_mapping" "example" {
  for_each = toset(var.api_gateway_stages)

  api_id      = aws_api_gateway_rest_api.this.id
  stage_name  = each.key
  domain_name = aws_api_gateway_domain_name.this.domain_name
  base_path   = each.key

  depends_on = [
    aws_api_gateway_stage.this
  ]
}

# ------------------------------------------------------------------------------------------
# Api gateway Usage Plan and API Key
# ------------------------------------------------------------------------------------------
resource "aws_api_gateway_usage_plan" "this" {
  for_each = toset(var.api_gateway_stages)

  name        = "${var.identifier}-${each.key}-${var.environment}"
  description = "Usage plan for stage: ${each.key} of api gateway: ${var.identifier}-${var.environment}"

  api_stages {
    api_id = aws_api_gateway_rest_api.this.id
    stage  = each.key
  }

  quota_settings {
    limit  = var.api_gateway_usage_plan_info[each.key].quota_limit
    offset = var.api_gateway_usage_plan_info[each.key].quota_offset
    period = var.api_gateway_usage_plan_info[each.key].quota_period
  }

  throttle_settings {
    burst_limit = var.api_gateway_usage_plan_info[each.key].throttle_burst
    rate_limit  = var.api_gateway_usage_plan_info[each.key].throttle_rate
  }

  depends_on = [
    aws_api_gateway_stage.this
  ]
}

resource "aws_api_gateway_api_key" "this" {
  for_each = toset(var.api_gateway_stages)

  name = "${var.identifier}-${each.value}-${var.environment}"
}

resource "aws_api_gateway_usage_plan_key" "this" {
  for_each = aws_api_gateway_api_key.this

  key_id        = each.value.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.this[each.key].id
}
