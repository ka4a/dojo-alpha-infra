output "mysql_host_name" {
  value = aws_db_instance.mysql_rds.endpoint
}
output "mysql_username" {
  value = var.database_root_username
}
output "mysql_password" {
  value = var.database_root_password
  sensitive = true
}
