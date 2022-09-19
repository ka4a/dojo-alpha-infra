variable "customer_name" {}
variable "environment" {}
variable "common_tags" {
  type = map
  default = {}
  description = "Additional tags to apply to resources"
}

variable "cluster_instance_class" {
  default = "db.r5.large"
}

variable "engine_version" {
  default = "4.0.0"
}
variable "family" {
  default = "docdb4.0"
}

variable "mongo_username" {
  default = "edxadmin"
}
variable "mongo_password" {}

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
