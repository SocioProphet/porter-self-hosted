output "db_instance_port" {
  description = "The port of the resulting RDS DB."
  value       = module.db.db_instance_port
}

output "db_instance_address" {
  description = "The address of the resulting RDS DB."
  value       = module.db.db_instance_address
}

output "db_instance_username" {
  description = "The username for the resulting RDS DB."
  value       = module.db.db_instance_username
  sensitive = true
}

output "db_master_password" {
  description = "The password for the resulting RDS DB."
  value       = module.db.db_master_password
  sensitive = true
}