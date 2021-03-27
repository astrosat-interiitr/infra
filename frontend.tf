module "frontend" {
  source          = "./modules/s3-website"
  bucket_name     = "${local.name}-bucket"
  domain_name     = local.domain_name
  certificate_arn = module.acm-us-east-1.this_acm_certificate_arn
  aliases         = ["www.${local.domain_name}"]

  route53_zone_id = data.aws_route53_zone.this.zone_id
}
