output "vpc_id" {
  description = "The resulting id of the VPC."
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "The IDs of the created private subnets."
  value = module.vpc.private_subnets
}

output "database_subnets" {
  description = "The IDs of the created database subnets."
  value = module.vpc.database_subnets
}

output "vpc_cidr_block" {
    description = "The CIDR block of the created VPC."
    value = module.vpc.vpc_cidr_block
}