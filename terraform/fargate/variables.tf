# ------------------------------------------------------------------------------------------
# Common
# ------------------------------------------------------------------------------------------
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

variable "sns_email" {
  description = "The email which will be used to send the SNS notifications"
  type        = string
}

variable "root_domain_name" {
  description = "The domain name of the public hosted zone"
  type        = string
}

variable "lb_subdomain" {
  description = "The subdomain which will be used to create the CNAME of the load balancer"
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
# Network Variables
# ------------------------------------------------------------------------------------------
variable "vpc_id" {
  description = "The Id of the vpc where the resources will be placed into"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The Cidr block of the vpc where the resources will be placed into"
  type        = string
}

variable "public_subnets_ids" {
  description = "The list of the public subnets ids"
  type        = list(string)
}

variable "private_subnets_ids" {
  description = "The list of the private subnets ids"
  type        = list(string)
}

# ------------------------------------------------------------------------------------------
# ECS Variables
# ------------------------------------------------------------------------------------------
variable "ecs_service_desired_count" {
  description = "The desired number of containers in the Fargate cluster"
  type        = number
}

variable "ecs_autoscaling_min_capacity" {
  description = "The minimum number of containers that should be running in the cluster and that the autoscaler will enforce"
  type        = number
}

variable "ecs_autoscaling_max_capacity" {
  description = "The maximum number of containers that the autoscaler will scale to"
  type        = number
}

variable "source_code_repo_id" {
  description = "The repo Id where the source code of the container is present"
  type        = string
}

variable "source_code_branch_name" {
  description = "The branch name where the source code of the container needs to be taken from"
  type        = string
}
