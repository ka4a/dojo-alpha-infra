variable "customer_domain" {}

variable "customer_name" {}
variable "environment" {}
variable "common_tags" {
  type = map
  default = {}
  description = "Additional tags to apply to resources"
}

variable "enable_route53" {
  type = bool
  default = true
}

variable "route53_subdomains" {
  default = [
    "preview",
    "studio",
    "discovery",
    "authn",
    "learning",
    "account",
    "profile",
    "dojo-admin",
    "dojo-grader",
    "enterprise-admin",
    "enterprise-lms",
    "enterprise-analytics",
    "enterprise-catalog",
    "license-manager",
    "lti-producer"
  ]
}

variable "vpc_id" {
  type = string
  description = "Vpc Id"
}

variable "private_net_cidr_blocks" {
  type = list
  description = "List of CIDR blocks of private subnets"
}

variable "private_net_ids" {
  type = list
  description = "List of IDs of private subnets"
}

variable "public_net_ids" {
  type = list
  description = "List of IDs of public subnets"
}

variable "lb_idle_timeout" {
  default = 60
}

variable enable_https {
  description = "Cannot enable HTTPS until there is a valid customer_domain certificate"
  default = true
}

variable "lb_ssl_security_policy" {
  description = "The AWS ssl security policy to be used by load balancer"
  default = "ELBSecurityPolicy-2016-08"
}

variable "s3_storage_policy_arn" {
  type = string
  description = "IAM policy ARN for S3 storage access"
}
