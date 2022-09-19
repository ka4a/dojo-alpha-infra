variable "region" {
  type = string
}

variable "common_tags" {
  type = map
  default = {}
}

variable "customer_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_cidr" {
  default = "10.121.0.0/16"
}

variable "azs" {
  type = list
}

variable "subnets_public" {
  type = list
  default = ["10.121.16.0/24" , "10.121.17.0/24"]
}

variable "subnets_private" {
  type = list
  default = ["10.121.8.0/24" , "10.121.9.0/24"]
}
