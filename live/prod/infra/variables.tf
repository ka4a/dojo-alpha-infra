variable "aws_region" {
  type        = string
  description = "Project's resources region location for AWS"
}
variable "aws_azs" {
  type        = list(string)
  default     = [
    "a",
    "b"
  ]
  description = "Array containing two AWS AZ to place resources in"
}
variable "aws_vpc_cidr" {
  default = "10.121.0.0/16"
}
variable "aws_subnets_public" {
  type = list
  default = ["10.121.16.0/24" , "10.121.17.0/24"]
}

variable "aws_subnets_private" {
  type = list
  default = ["10.121.8.0/24" , "10.121.9.0/24"]
}
variable "enable_route53" {
  type        = bool
  default     = true
  description = "Enables setup of Route53 zone"
}
variable "domain_name" {
  type        = string
  description = "Domain name for zone and cert creation"
}
variable "customer_name" {
  type        = string
  description = "Customer name for resource naming"
}
variable "environment" {
  type        = string
  description = "Env name for tags and other stuf"
}
variable "enable_email" {
  type        = bool
  default     = true
  description = "Enables setup of SES configuration and Route53 records for 'domain_name'"
}
variable "sandbox_emails" {
  type        = list(string)
  description = "Test emails to be used as recipients until you get out of the sandbox (check Note) SES configuration to be out of the sandbox"
}
variable "internal_emails" {
  type        = list(string)
  description = "List of emails to be used by the OpenedX instance (no-reply added as default)"
}
variable "mysql_user" {
    type = string
    default = "edxadmin"
    description = "RDS MySQL Mysql user"
}
variable "mysql_password" {
    type = string
    description = "RDS MySQL Password"
    validation {
      condition     = length(var.mysql_password) > 7
      error_message = "The mysql_password value must be minimun lenght of 8 characters."
    }
}
variable "mysql_dbname" {
    type = string
    default = "openedx"
    description = "Database name"
}
variable "mysql_db_family" {
  type = string
  default = "mysql5.7"
  description = "(optional) describe your variable"
}
variable "mysql_major_engine_version" {
  type = string
  default = "5.7"
  description = "Major mysql engine version"
}
variable "mysql_engine_ver" {
    type = string
    default = "5.7.26"
    description = "Database engine ver"
}
variable "mysql_storage_size" {
    type = string
    default = 30
    description = "(optional) describe your variable"
}
variable "mysql_instance" {
    type = string
    default = "db.t2.large"
    description = "(optional) describe your variable"
}
variable "elasticsearch_version" {
  description = "The version of Elasticsearch to deploy"
  type        = string
  default     = "7.1"
}
variable "elasticsearch_instance_type" {
  default = "t3.small.elasticsearch"
}
variable "docdb_version" {
  description = "The version of MongoDB to deploy"
  type        = string
  default     = "4.0" 
}
variable "docdb_instance" {
    type = string
    default = "db.r5.large"
    description = "AWS DocumentDB cluster instance class"
}
variable "mongo_user" {
    type = string
    default = "edxadmin"
    description = "AWS DocumentDB admin user"
}
variable "mongo_password" {
    type = string
    description = "AWS DocumentDB admin password"
    validation {
      condition     = length(var.mongo_password) > 7
      error_message = "The mongo_password value must be minimun lenght of 8 characters."
    }
}
variable "redis_instance" {
    type = string
    default = "cache.m4.large"
    description = "AWS ElastiCache Redis instance size"
}
variable "memcached_instance" {
    type = string
    default = "cache.m4.large"
    description = "AWS ElastiCache Memcached instance size"
}
