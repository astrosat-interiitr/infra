resource "aws_s3_bucket" "this" {
  bucket  = "${local.name}-backend-bucket"
  acl = "public-read"
}

module "backend" {
  source = "./modules/service/"
  name   = "${local.name}-backend"
  cpu    = 1024
  memory = 4096

  image     = "134227094594.dkr.ecr.ap-south-1.amazonaws.com/astrosat-backend"
  image_tag = "latest"
  port      = 80
  lb_port   = 443

  desired_count   = 1
  cluster_arn     = aws_ecs_cluster.this.arn
  private_subnets = module.vpc.public_subnets
  vpc_id          = module.vpc.vpc_id
  cluster_name    = aws_ecs_cluster.this.name
  cidr            = module.vpc.vpc_cidr_block
  healthcheck     = "/health-check"
  lb_arn          = aws_alb.this.arn

  https_certificate_arn = module.acm.this_acm_certificate_arn

  secrets = [
    {
      "key"    = "dbName"
      "value"  = "postgres"
      "secure" = true
    },
    {
      "key"    = "dbUser"
      "value"  = module.aurora_postgresql.this_rds_cluster_master_username
      "secure" = true
    },
    {
      "key"    = "dbPassword"
      "value"  = module.aurora_postgresql.this_rds_cluster_master_password
      "secure" = true
    },
    {
      "key"    = "dbHost"
      "value"  = module.aurora_postgresql.this_rds_cluster_endpoint
      "secure" = true
    },
    {
      "key"    = "dbPort"
      "value"  = module.aurora_postgresql.this_rds_cluster_port
      "secure" = true
    },

    {
      "key"    = "AWS_STORAGE_BUCKET_NAME"
      "value"  = "${local.name}-backend-bucket"
      "secure" = true
    },
        {
      "key"    = "AWS_REGION"
      "value"  = local.region
      "secure" = false
    },

  ]

  tags = local.tags
}
