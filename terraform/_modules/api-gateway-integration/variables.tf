variable "identifier" {
  description = "An identifier which will be used to create the unique name of each resource"
  type        = string
}

variable "environment" {
  description = "The environment of the deployment"
  type        = string

  validation {
    condition     = contains(["test", "acceptance", "production"], var.environment)
    error_message = "The environment variable must be test, acceptance or production."
  }
}

variable "suffix" {
  description = "A unique id which will be suffixed to each resource"
  type        = string
}

variable "sns_topic_arn" {
  description = "The ARN of the topic where the alarms will send notifications"
  type        = string
}

variable "request_validator_map" {
  description = "A map with the request validators names and their ids"
  type        = map(string)
}

variable "api_gateway_id" {
  description = "The Id of the api gateway"
  type        = string
}

variable "lambda_name" {
  description = "Name of the lambda"
  type        = string
}

variable "lambda_description" {
  description = "Description of the lambda"
  type        = string
}

variable "lambda_runtime" {
  description = "Runtime of the lambda"
  type        = string
}

variable "lambda_timeout" {
  description = "Timeout of the lambda"
  type        = number
}

variable "lambda_handler" {
  description = "Handler of the lambda"
  type        = string
}

variable "lambda_architectures" {
  description = "Architectures of the lambda"
  type        = list(string)
}

variable "lambda_memory_size" {
  description = "Memory of the lambda"
  type        = number
}

variable "lambda_ephemeral_storage_size" {
  description = "The ephemeral storage size of the lambda"
  type        = number
}

variable "lambda_layers" {
  description = "Layers to attach to the lambda"
  type        = list(string)
}

variable "lambda_cloudwatch_logs_retention_in_days" {
  description = "Log retentention in days for the lambda"
  type        = number
}

variable "lambda_source_code_bucket" {
  description = "The s3 bucket where the source code will be uploaded"
  type        = string
}

variable "lambda_attach_policy" {
  description = "Whether to attach a custom policy to the lambda"
  type        = bool
}
variable "lambda_policy_json" {
  description = "The policy to attach in json to the lambda"
  type        = string
}

variable "lambda_environment_variables" {
  description = "The environment variables that will associated with the lambda"
  type        = map(string)
}

variable "lambda_path" {
  description = "Where to find the lambda"
  type        = string
}

variable "integration_http_method" {
  description = "HTTP method of the integration for the lambda"
  type        = string
}

variable "integration_full_path" {
  description = "The path of the integration for the lambda"
  type        = string
}

variable "integration_resource_id" {
  description = "The Id of the api gateway resource where the lambda will be attached to"
  type        = string
}

variable "integration_request_validator" {
  description = "The request validator to associate to the integration"
  type        = string
}

variable "integration_request_model" {
  description = "The model to associate to the integration"
  type        = map(string)
}

variable "integration_request_parameters" {
  description = "The parameters to validate in the request"
  type        = map(string)
}

variable "aliases" {
  description = "A map of <stage>:<version> which will associate the lambda alias <stage> with the version"
  type        = map(string)
}
