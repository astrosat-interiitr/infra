output "master_username" {
  value = module.aurora_postgresql.this_rds_cluster_master_username
}

output "master_password" {
  value     = module.aurora_postgresql.this_rds_cluster_master_password
  sensitive = true
}


output "db_name" {
  value = module.aurora_postgresql.this_rds_cluster_database_name
}
