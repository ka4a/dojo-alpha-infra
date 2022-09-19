output "rds_host_name" {
  value = module.sql.mysql_host_name
}

output "rds_user" {
  value = module.sql.mysql_username
}

output "rds_password" {
  value = module.sql.mysql_password
  sensitive = true
}

output "mongo_endpoint" {
  value = module.docdb.mongo_endpoint
}

output "mongo_user" {
  value = module.docdb.mongo_user
}

output "mongo_password" {
  value = module.docdb.mongo_password
  sensitive = true
}

output "elasticsearch_endpoint" {
  value = module.elasticsearch.elasticsearch
}

output "redis_endpoint" {
  value = tolist(module.cache.redis_nodes.*.address)[0]
}

output "memcached_endpoint" {
  value = tolist(module.cache.memcached_nodes.*.address)[0]
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "openedx_app_sg_id" {
  value = module.openedx.edxapp_security_group_id
}

output "packer_sg_id" {
  value = module.openedx.packer_security_group_id
}

output "vpc_private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "openedx_instance_profile" {
  value = module.openedx.edxapp_instance_profile
}

output "edxapp_lb_target_group_arn" {
  value = module.openedx.edxapp_lb_target_group_arn
}

output "openedx_s3_storage_bucket_name" {
  value = module.s3.s3_storage_bucket_name
}

output "openedx_s3_storage_access_key" {
  value = module.s3.s3_storage_user_access_key
}

output "openedx_s3_storage_access_secret" {
  value = module.s3.s3_storage_user_secret_key
  sensitive = true
}

output "openedx_s3_tracking_logs_bucket_name" {
  value = module.s3.s3_tracking_logs_bucket_name
}

output "openedx_s3_tracking_logs_access_key" {
  value = module.s3.s3_tracking_logs_user_access_key
}

output "openedx_s3_tracking_logs_access_secret" {
  value = module.s3.s3_tracking_logs_user_secret_key
  sensitive = true
}
