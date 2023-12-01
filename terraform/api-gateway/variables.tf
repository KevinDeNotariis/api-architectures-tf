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

variable "root_domain" {
  description = "The root domain of the hosted zone where the api gateway alias will be created"
  type        = string
}

variable "public_hosted_zone_id" {
  description = "The id of the public hosted zone where the api gateway alias will be created"
  type        = string
}

variable "sns_email" {
  description = "The email which will be used to send the SNS notifications"
  type        = string
}

variable "strings_mapping_ssm_parameter_name" {
  description = "The name of the parameter store paramater that holds the strings mapping"
  type        = string
}

variable "strings_mapping_ssm_parameter_arn" {
  description = "The arn of the parameter store paramater that holds the strings mapping"
  type        = string
}

# ------------------------------------------------------------------------------------------
# Api gateway variables
# ------------------------------------------------------------------------------------------
variable "api_gateway_subdomain" {
  description = "The subdomain of the api gateway. If the 'root_domain' is 'hello.world', and this variable is 'api', then the record 'api.hello.world' will be created"
  type        = string
}

variable "api_gateway_stages" {
  description = "The stages that needs to be created for the API gateway"
  type        = list(string)
  default     = ["test"]
}

variable "api_gateway_usage_plan_info" {
  description = "The usage plan information of the api keys scoped per stage. Every stage will be a key in the map with all the info"
  type = map(object({
    quota_limit    = number
    quota_offset   = number
    quota_period   = string
    throttle_burst = number
    throttle_rate  = number
  }))
  default = {
    "test" = {
      quota_limit    = 1000
      quota_offset   = 0
      quota_period   = "DAY"
      throttle_burst = 10
      throttle_rate  = 10
    }
  }
}

variable "api_gateway_stage_logs_retention_id_days" {
  description = "The log retention in days of the stages logs"
  type        = number
  default     = 30
}
