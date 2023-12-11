resource "aws_cloudwatch_dashboard" "this" {
  dashboard_name = "${var.identifier}-${var.environment}-${random_id.this.hex}"
  dashboard_body = jsonencode(
    {
      widgets = concat(
        module.fargate.cloudwatch_dashboard_widgets
      )
    }
  )
}
