data "aws_route53_zone" "this" {
  name         = local.domain_name
  private_zone = false
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> v2.0"

  domain_name = local.domain_name
  zone_id     = data.aws_route53_zone.this.zone_id

  subject_alternative_names = [
    "*.${local.domain_name}",
  ]

  tags = {
    Name = local.domain_name
  }
}

module "acm-us-east-1" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> v2.0"

  providers = {
    aws = aws.us-east-1
  }

  domain_name = local.domain_name
  zone_id     = data.aws_route53_zone.this.zone_id

  subject_alternative_names = [
    "*.${local.domain_name}",
  ]

  tags = {
    Name = local.domain_name
  }
}
