data "aws_route53_zone" "current" {
  name = local.root_domain_name
}
