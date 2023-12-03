# -----------------------------------------------------------------------------
# WAF
# -----------------------------------------------------------------------------
resource "aws_wafv2_web_acl" "this" {
  name        = "${var.identifier}-${var.environment}-${random_id.this.hex}"
  description = "Waf to protect APIs"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "ip-rate-limit"
    priority = 10

    action {
      block {}
    }

    statement {
      rate_based_statement {
        # Limit of requests per 5 minutes
        limit              = 1000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "ip-rate-limit"
      sampled_requests_enabled   = false
    }
  }

  rule {
    name     = "block-bad-ips"
    priority = 20

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "block-bad-ips"
      sampled_requests_enabled   = false
    }
  }

  rule {
    name     = "block-aws-managed-rule-set"
    priority = 30

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "block-aws-managed-rule-set"
      sampled_requests_enabled   = false
    }
  }

  # Commenting the below rule as it will block requests made by `curl`
  # 
  # rule {
  #   name     = "aws-managed-bot-protection"
  #   priority = 40

  #   override_action {
  #     none {}
  #   }

  #   statement {
  #     managed_rule_group_statement {
  #       name        = "AWSManagedRulesBotControlRuleSet"
  #       vendor_name = "AWS"

  #       managed_rule_group_configs {
  #         aws_managed_rules_bot_control_rule_set {
  #           inspection_level = "COMMON"
  #         }
  #       }
  #     }
  #   }

  #   visibility_config {
  #     cloudwatch_metrics_enabled = true
  #     metric_name                = "aws-managed-bot-protection"
  #     sampled_requests_enabled   = false
  #   }
  # }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.identifier}-${var.environment}-waf-${random_id.this.hex}"
    sampled_requests_enabled   = false
  }
}

# -----------------------------------------------------------------------------
# WAF Logging
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "this" {
  # The name must be prefixed with `aws-waf-logs`
  name              = "aws-waf-logs-${var.identifier}-${var.environment}-waf-${random_id.this.hex}"
  retention_in_days = 7
}

resource "aws_wafv2_web_acl_logging_configuration" "this" {
  log_destination_configs = [aws_cloudwatch_log_group.this.arn]
  resource_arn            = aws_wafv2_web_acl.this.arn
}

resource "aws_cloudwatch_log_resource_policy" "this" {
  policy_document = data.aws_iam_policy_document.this.json
  policy_name     = "${var.identifier}-${var.environment}-waf-${random_id.this.hex}"
}

data "aws_iam_policy_document" "this" {
  statement {
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["${aws_cloudwatch_log_group.this.arn}:*"]

    condition {
      test     = "ArnLike"
      values   = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
      variable = "aws:SourceArn"
    }

    condition {
      test     = "StringEquals"
      values   = [tostring(data.aws_caller_identity.current.account_id)]
      variable = "aws:SourceAccount"
    }
  }
}
