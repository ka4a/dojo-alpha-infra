variable "customer_name" {}
variable "environment" {}
variable "common_tags" {
  type = map
  default = {}
  description = "Additional tags to apply to resources"
}

variable "edxapp_security_group_id" {}
variable "packer_security_group_id" {}

variable "redis_node_type" {
  default = "cache.m4.large"
}
variable "redis_parameter_group_name" {
  default = "default.redis6.x"
}
variable "redis_port" {
  default = 6379
}

variable "vpc_id" {
    type = string
    description = "Vpc Id"
}

variable "private_net_ids" {
  type = list
  description = "List of IDs of private subnets"
}

variable "memcached_node_type" {
  default = "cache.m4.large"
}
variable "memcached_num_cache_nodes" {
  default = 1
}
variable "memcached_engine_version" {
  type = string
  default = "1.5.16"
  description = "Memcached engine version"
}
variable "memcached_parameter_group_name" {
  default = "default.memcached1.5"
}
variable "memcached_port" {
  default = 11211
}
