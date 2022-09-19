variable "environment" {
  type = string
}
variable "instance_profile" {
  type = string
}
variable "edxapp_lb_target_group_arn" {
  type = string
}
variable "vpc_private_subnet_ids" {
  type = list(string)
}
variable "app_instance_image_id" {
  type = string
}
variable "security_group_ig" {
  type = string
}
variable "instance_type" {
  type = string
  default = "t3.xlarge"
}
