module "aurora_postgresql" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 3.0"

  name              = "${local.name}-postgresql"
  engine            = "aurora-postgresql"
  engine_mode       = "serverless"
  storage_encrypted = true

  vpc_id                = module.vpc.vpc_id
  subnets               = module.vpc.database_subnets
  create_security_group = true
  allowed_cidr_blocks   = [module.vpc.vpc_cidr_block, ]

  replica_scale_enabled = false
  replica_count         = 0


  apply_immediately   = true
  skip_final_snapshot = true

  enable_http_endpoint = true


  scaling_configuration = {
    auto_pause               = true
    min_capacity             = 2
    max_capacity             = 8
    seconds_until_auto_pause = 300
    timeout_action           = "ForceApplyCapacityChange"
  }
}
