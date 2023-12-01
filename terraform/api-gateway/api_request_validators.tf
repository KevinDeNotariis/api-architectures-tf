resource "aws_api_gateway_request_validator" "body_only" {
  name                        = "body-only"
  rest_api_id                 = aws_api_gateway_rest_api.this.id
  validate_request_body       = true
  validate_request_parameters = false
}
resource "aws_api_gateway_request_validator" "params_only" {
  name                        = "params-only"
  rest_api_id                 = aws_api_gateway_rest_api.this.id
  validate_request_body       = false
  validate_request_parameters = true
}
resource "aws_api_gateway_request_validator" "all" {
  name                        = "all"
  rest_api_id                 = aws_api_gateway_rest_api.this.id
  validate_request_body       = true
  validate_request_parameters = true
}
resource "aws_api_gateway_request_validator" "none" {
  name                        = "none"
  rest_api_id                 = aws_api_gateway_rest_api.this.id
  validate_request_body       = false
  validate_request_parameters = false
}
