resource "aws_api_gateway_resource" "string" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "string"
}

resource "aws_api_gateway_resource" "string_replace" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.string.id
  path_part   = "replace"
}
