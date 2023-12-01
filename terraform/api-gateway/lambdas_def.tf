data "aws_iam_policy_document" "lambda_replace_strings" {
  statement {
    actions = [
      "ssm:GetParameters",
      "ssm:GetParameter"
    ]
    resources = [var.strings_mapping_ssm_parameter_arn]
  }
}

locals {
  lambdas = {
    replace_strings = {
      lambda = {
        name          = "post-replace-strings"
        description   = "Replace some strings with others"
        path          = "${local.lambdas_folder_path}/replace-strings"
        attach_policy = true
        policy_json   = data.aws_iam_policy_document.lambda_replace_strings.json
        environment_variables = {
          STRINGS_MAPPING_PARAMETER_NAME = var.strings_mapping_ssm_parameter_name
        }
      }
      integration = {
        http_method       = "POST"
        full_path         = "string/replace"
        resource_id       = aws_api_gateway_resource.string_replace.id
        request_validator = "body-only"
        request_model = {
          name         = "StringReplace"
          description  = "Schema to replace in string other strings"
          content_type = "application/json"
          schema = jsonencode({
            type = "object",
            properties = {
              content = {
                type = "string"
              },
            }
          })
        }
      }
      aliases = {
        test = "$LATEST"
        prod = "4"
      }
    }
  }
}
