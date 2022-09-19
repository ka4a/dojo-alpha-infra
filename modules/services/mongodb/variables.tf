variable "number_of_instances" {}
variable "image_id" {}
variable "instance_type" {}

variable "customer_name" {}
variable "environment" {}
variable "common_tags" {
  type = map
  default = {}
  description = "Additional tags to apply to resources"
}

variable "openedx_key_pair_name" {}
variable "edxapp_security_group_id" {}
variable "packer_security_group_id" {}
