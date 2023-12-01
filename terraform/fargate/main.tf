module "sns" {
  source = "github.com/KevinDeNotariis/terraform-modules//terraform/sns"

  identifier  = var.identifier
  environment = var.environment
  suffix      = var.suffix

  sns_general_subscriptions = [
    {
      protocol = "email"
      endpoint = var.sns_email
    }
  ]
}

module "loadbalancer" {
  source = "github.com/KevinDeNotariis/terraform-modules//terraform/loadbalancer"

  identifier  = var.identifier
  environment = var.environment
  suffix      = var.suffix

  root_domain_name             = var.root_domain_name
  lb_subdomain                 = var.lb_subdomain
  lb_cname_ttl                 = 5
  vpc_id                       = var.vpc_id
  vpc_cidr_block               = var.vpc_cidr_block
  public_subnets_ids           = var.public_subnets_ids
  lb_target_type               = "ip"
  enable_green_lb_target_group = true
  lb_ignore_listeners_changes  = true
}

module "ecs" {
  source = "github.com/KevinDeNotariis/terraform-modules//terraform/ecs"

  identifier  = var.identifier
  environment = var.environment
  suffix      = var.suffix

  vpc_id                    = var.vpc_id
  vpc_cidr_block            = var.vpc_cidr_block
  private_subnets_ids       = var.private_subnets_ids
  lb_arn                    = module.loadbalancer.lb_arn
  lb_target_group_arn       = module.loadbalancer.lb_target_group_arn
  ecr_replication_region    = "eu-west-1"
  ecs_service_desired_count = var.ecs_service_desired_count

  depends_on = [
    module.loadbalancer
  ]
}

module "autoscaling_ecs" {
  source = "github.com/KevinDeNotariis/terraform-modules//terraform/autoscaling-ecs"

  identifier  = var.identifier
  environment = var.environment
  suffix      = var.suffix

  min_capacity     = var.ecs_autoscaling_min_capacity
  max_capacity     = var.ecs_autoscaling_max_capacity
  ecs_cluster_name = module.ecs.ecs_cluster_name
  ecs_service_name = module.ecs.ecs_service_name
  scaling_sns_arn  = module.sns.sns_general_arn
}

module "codepipeline" {
  source = "github.com/KevinDeNotariis/terraform-modules//terraform/codepipeline"

  identifier  = var.identifier
  environment = var.environment
  suffix      = var.suffix

  vpc_id              = var.vpc_id
  private_subnets_ids = var.private_subnets_ids
  source_repo_id      = var.source_code_repo_id
  source_branch_name  = var.source_code_branch_name

  deploy_platform = "ECS"
  deploy_ecs_config = {
    cluster_name               = module.ecs.ecs_cluster_name
    service_name               = module.ecs.ecs_service_name
    execution_role_arn         = module.ecs.ecs_execution_role_arn
    execution_role_name        = module.ecs.ecs_execution_role_name
    family                     = module.ecs.ecs_family
    network_mode               = module.ecs.ecs_network_mode
    memory                     = module.ecs.ecs_memory
    cpu                        = module.ecs.ecs_cpu
    lb_listener_arn            = module.loadbalancer.lb_listener_arn
    lb_target_group_blue_name  = module.loadbalancer.lb_target_group_name
    lb_target_group_green_name = module.loadbalancer.lb_target_group_green_name
    ecr_repo_arn               = module.ecs.ecr_repo_arn
    ecr_repo_name              = module.ecs.ecr_repo_name
    ecr_repo_url               = module.ecs.ecr_repo_url
    container_name             = module.ecs.ecs_container_name
    container_log_group_name   = module.ecs.ecs_container_log_group_name
    container_stream_prefix    = module.ecs.ecs_container_stream_prefix
  }

  build_env_variables = {
    CONTAINER_ENV_API_KEY                        = "${random_password.api_key.result}"
    CONTAINER_ENV_AWS_REGION                     = "${data.aws_region.current.name}"
    CONTAINER_ENV_STRINGS_MAPPING_PARAMETER_NAME = "${var.strings_mapping_ssm_parameter_name}"
  }

  deploy_trigger_target_arn        = module.sns.sns_general_arn
  pipeline_notification_target_arn = module.sns.sns_general_arn

  depends_on = [
    module.ecs,
  ]
}
