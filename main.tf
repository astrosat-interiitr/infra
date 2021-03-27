locals {
  name   = "astrosat"
  region = "ap-south-1"
  tags = {
    Owner       = "AstroSat"
    Environment = "prod"
  }
  domain_name = "cosmoscope.in"
}

provider "aws" {
  region = "ap-south-1"
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}



