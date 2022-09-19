variable "customer_name" {}
variable "environment" {}
variable "common_tags" {
  type = map
  default = {}
  description = "Additional tags to apply to resources"
}

variable "engine_version" {
  default = "5.7"
}
variable "instance_class" {
  default = "db.t2.large"
}
variable "allocated_storage" {}
variable "max_allocated_storage" {
  default = 100
}

variable "database_root_username" {}
variable "database_root_password" {}

variable "vpc_id" {
    type = string
    description = "Vpc Id"
}

variable "private_net_ids" {
  type = list
  description = "List of IDs of private subnets"
}

variable "edxapp_security_group_id" {}
variable "packer_security_group_id" {}

variable "number_of_replicas" {
  default = 0
}

variable "enable_multi_az" {
  default = false
}

variable "enable_replica_multi_az" {
  default = false
}

variable "replica_extra_security_group_ids" {
  default = []
}

variable "replica_publicly_accessible" {
  default = false
}

variable "skip_final_snapshot" {
  type = bool
  default = true
  description = "Skip final snapshot"
}
