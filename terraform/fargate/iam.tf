data "aws_iam_policy_document" "ssm_parameter_read" {
  statement {
    actions = [
      "ssm:GetParameters",
      "ssm:GetParameter"
    ]
    resources = [var.strings_mapping_ssm_parameter_arn]
  }
}

resource "aws_iam_role_policy" "ecs_ssm_parameter_read" {
  role   = module.ecs.ecs_task_role_name
  policy = data.aws_iam_policy_document.ssm_parameter_read.json
}
