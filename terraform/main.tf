# -----------------------------------------------------------------------------
# Network
# -----------------------------------------------------------------------------
module "network" {
  source = "github.com/KevinDeNotariis/terraform-modules//terraform/network-simple?ref=v2.0.1"

  identifier  = var.identifier
  environment = var.environment
  suffix      = random_id.this.hex

  vpc_cidr_block           = "10.150.0.0/24"
  private_subnets_new_bits = 3
  public_subnets_new_bits  = 3
}

# -----------------------------------------------------------------------------
# Api Gateway with Lambda Integrations
# -----------------------------------------------------------------------------
module "api_gateway" {
  source = "./api-gateway"

  identifier  = var.identifier
  environment = var.environment
  suffix      = random_id.this.hex

  sns_email                          = local.sns_email
  root_domain                        = local.root_domain_name
  public_hosted_zone_id              = data.aws_route53_zone.current.zone_id
  strings_mapping_ssm_parameter_arn  = aws_ssm_parameter.replace_strings_map.arn
  strings_mapping_ssm_parameter_name = aws_ssm_parameter.replace_strings_map.name
  waf_arn                            = aws_wafv2_web_acl.this.arn

  api_gateway_subdomain = "api.${var.identifier}"
  api_gateway_stages    = ["test", "prod"]
  api_gateway_usage_plan_info = {
    test = {
      quota_limit    = 1000
      quota_offset   = 0
      quota_period   = "DAY"
      throttle_burst = 10
      throttle_rate  = 10
    }
    prod = {
      quota_limit    = 1000
      quota_offset   = 0
      quota_period   = "DAY"
      throttle_burst = 10
      throttle_rate  = 10
    }
  }
  api_gateway_stage_logs_retention_id_days = 7
}

# -----------------------------------------------------------------------------
# Fargate
# -----------------------------------------------------------------------------
module "fargate" {
  source = "./fargate"

  identifier  = var.identifier
  environment = var.environment
  suffix      = random_id.this.hex

  sns_email                          = local.sns_email
  root_domain_name                   = local.root_domain_name
  lb_subdomain                       = "fargate.${var.identifier}"
  strings_mapping_ssm_parameter_arn  = aws_ssm_parameter.replace_strings_map.arn
  strings_mapping_ssm_parameter_name = aws_ssm_parameter.replace_strings_map.name
  waf_arn                            = aws_wafv2_web_acl.this.arn

  vpc_id              = module.network.vpc_id
  public_subnets_ids  = module.network.public_subnets_ids
  private_subnets_ids = module.network.private_subnets_ids
  vpc_cidr_block      = module.network.vpc_cidr_block

  ecs_service_desired_count    = 2
  ecs_autoscaling_min_capacity = 2
  ecs_autoscaling_max_capacity = 4
  source_code_repo_id          = "KevinDeNotariis/fargate-api-sample"
  source_code_branch_name      = "main"

  depends_on = [module.network]
}
