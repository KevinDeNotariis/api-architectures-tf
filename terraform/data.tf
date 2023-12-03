data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_route53_zone" "current" {
  name = local.root_domain_name
}
