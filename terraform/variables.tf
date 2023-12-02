variable "identifier" {
  description = "An identifier which will be used to create the unique name of each resource"
  type        = string
}

variable "region" {
  description = "The AWS region where the resources will be deployed"
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