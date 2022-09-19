output "mongo_endpoint" {
  value = module.documentdb-cluster.endpoint
}

output "mongo_user" {
  value = var.mongo_username
}

output "mongo_password" {
  value = var.mongo_password
  sensitive = true
}
