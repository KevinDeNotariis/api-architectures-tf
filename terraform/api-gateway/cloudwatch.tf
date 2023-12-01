resource "aws_cloudwatch_metric_alarm" "api_gateway_latency" {
  alarm_name                = "${local.identifier}-api-gateway-latency-${var.suffix}"
  alarm_description         = "This metric monitors the latency (p95) of the api gateway ${local.identifier}-${var.suffix}"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 5
  metric_name               = "Latency"
  namespace                 = "AWS/ApiGateway"
  period                    = 60
  extended_statistic        = "p95"
  threshold                 = 1000
  unit                      = "Milliseconds"
  insufficient_data_actions = []
  actions_enabled           = true

  dimensions = {
    ApiName = aws_api_gateway_rest_api.this.name
  }

  alarm_actions = [aws_sns_topic.this.arn]
  ok_actions    = [aws_sns_topic.this.arn]
}

resource "aws_cloudwatch_metric_alarm" "api_gateway_4xx" {
  alarm_name                = "${local.identifier}-api-gateway-4xx-${var.suffix}"
  alarm_description         = "This metric monitors the 4xx responses of the api gateway ${local.identifier}-${var.suffix}"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 5
  threshold                 = 0.02
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"
  actions_enabled           = true

  metric_query {
    id          = "errorRate"
    label       = "4XX Rate (%)"
    expression  = "error4xx / count"
    return_data = true
  }

  metric_query {
    id    = "count"
    label = "Count"

    metric {
      metric_name = "Count"
      namespace   = "AWS/ApiGateway"
      period      = "60"
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        ApiName = aws_api_gateway_rest_api.this.name
      }
    }

    return_data = false
  }

  metric_query {
    id    = "error4xx"
    label = "4XX Error"

    metric {
      metric_name = "4XXError"
      namespace   = "AWS/ApiGateway"
      period      = "60"
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        ApiName = aws_api_gateway_rest_api.this.name
      }
    }

    return_data = false
  }

  alarm_actions = [aws_sns_topic.this.arn]
  ok_actions    = [aws_sns_topic.this.arn]
}

resource "aws_cloudwatch_metric_alarm" "api_gateway_5xx" {
  alarm_name                = "${local.identifier}-api-gateway-5xx-${var.suffix}"
  alarm_description         = "This metric monitors the 5xx responses of the api gateway ${local.identifier}-${var.suffix}"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 5
  threshold                 = 0.02
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"
  actions_enabled           = true

  metric_query {
    id          = "errorRate"
    label       = "5XX Rate (%)"
    expression  = "error5xx / count"
    return_data = true
  }

  metric_query {
    id    = "count"
    label = "Count"

    metric {
      metric_name = "Count"
      namespace   = "AWS/ApiGateway"
      period      = "60"
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        ApiName = aws_api_gateway_rest_api.this.name
      }
    }

    return_data = false
  }

  metric_query {
    id    = "error5xx"
    label = "5XX Error"

    metric {
      metric_name = "5XXError"
      namespace   = "AWS/ApiGateway"
      period      = "60"
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        ApiName = aws_api_gateway_rest_api.this.name
      }
    }

    return_data = false
  }

  alarm_actions = [aws_sns_topic.this.arn]
  ok_actions    = [aws_sns_topic.this.arn]
}

