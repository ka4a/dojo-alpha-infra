variable "customer_name" {}
variable "environment" {}
variable "common_tags" {
  type = map
  default = {}
  description = "Additional tags to apply to resources"
}
