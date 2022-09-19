variable "customer_name" {}
variable "environment" {}
variable "common_tags" {
  type = map
  default = {}
  description = "Additional tags to apply to resources"
}

variable "edxapp_security_group_id" {}
variable "packer_security_group_id" {}
variable "elasticsearch_instance_type" {
  default = "t3.small.elasticsearch"
}
variable "number_of_nodes" {
  default = 3
}
variable "elasticsearch_version" {
  type = string
  default = "7.1"
}
variable "create_iam_service_linked_role" {
  default = true
}
variable "vpc_id" {
    type = string
    description = "Vpc Id"
}
variable "private_net_ids" {
  type = list
  description = "List of IDs of private subnets"
}
