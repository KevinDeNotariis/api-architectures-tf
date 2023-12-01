resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  for_each = var.aliases

  alarm_name                = "${local.identifier}-${var.lambda_name}-${each.key}-errors-${var.suffix}"
  alarm_description         = "This metric monitors the errors of the lambda ${module.lambda_integration.lambda_function_name} of stage: ${each.key}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "Errors"
  namespace                 = "AWS/Lambda"
  period                    = 60
  statistic                 = "Maximum"
  threshold                 = 0
  unit                      = "Count"
  insufficient_data_actions = []
  actions_enabled           = true

  dimensions = {
    FunctionName    = module.lambda_integration.lambda_function_name
    ExecutedVersion = each.value
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  for_each = var.aliases

  alarm_name                = "${local.identifier}-${var.lambda_name}-${each.key}-duration-${var.suffix}"
  alarm_description         = "This metric monitors the duration of the lambda ${module.lambda_integration.lambda_function_name} of stage: ${each.key}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "Duration"
  namespace                 = "AWS/Lambda"
  period                    = 60
  statistic                 = "Maximum"
  threshold                 = 500
  unit                      = "Milliseconds"
  insufficient_data_actions = []
  actions_enabled           = true

  dimensions = {
    FunctionName    = module.lambda_integration.lambda_function_name
    ExecutedVersion = each.value
  }
  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "lambda_invocations" {
  for_each = var.aliases

  alarm_name                = "${local.identifier}-${var.lambda_name}-${each.key}-invocations-${var.suffix}"
  alarm_description         = "This metric monitors the number of invocations of the lambda ${module.lambda_integration.lambda_function_name} of stage: ${each.key}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "Invocations"
  namespace                 = "AWS/Lambda"
  period                    = 60
  statistic                 = "Maximum"
  threshold                 = 1000
  unit                      = "Count"
  insufficient_data_actions = []
  actions_enabled           = true

  dimensions = {
    FunctionName    = module.lambda_integration.lambda_function_name
    ExecutedVersion = each.value
  }
  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]
}
