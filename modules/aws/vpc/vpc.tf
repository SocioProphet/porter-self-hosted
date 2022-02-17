data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.10.0"

  name                 = "${var.env_name}-vpc"
  cidr                 = "10.99.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = var.private_subnets
  public_subnets       = var.public_subnets
  database_subnets     = var.database_subnets_enabled ? var.database_subnets : []
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${var.env_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.env_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.env_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}