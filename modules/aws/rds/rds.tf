resource "random_string" "postgres_password" {
  length = 16

  special = false
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4"

  name        = "rds-${var.env_name}"
  description = "Security group for RDS PG Access"
  vpc_id      = var.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PG access from within VPC"
      cidr_blocks = var.vpc_cidr_block
    },
  ]
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 3.0"

  identifier = "rds-${var.env_name}"

  engine               = "postgres"
  engine_version       = "13.6"
  family               = "postgres13"
  major_engine_version = "13"
  instance_class       = "db.t3.large"

  allocated_storage     = 10
  max_allocated_storage = 20
  storage_encrypted     = true

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  name     = replace(replace(var.env_name, "-", ""), "_", "")
  username = "porteruser"
  password = random_string.postgres_password.result
  port     = 5432

  multi_az               = true
  subnet_ids             = var.database_subnets
  vpc_security_group_ids = [module.security_group.security_group_id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_role_name                  = "rds-monitoring-role-${var.env_name}"
  monitoring_interval                   = 60
}
