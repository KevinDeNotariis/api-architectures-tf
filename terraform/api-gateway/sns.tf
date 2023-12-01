resource "aws_sns_topic" "this" {
  name = "${local.identifier}-api-gateway-and-lambdas-${var.suffix}"
}

resource "aws_sns_topic_subscription" "this" {
  topic_arn = aws_sns_topic.this.arn
  endpoint  = var.sns_email
  protocol  = "email"
}
