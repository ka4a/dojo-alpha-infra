environment = "prod"
customer_name = "dojo-dx"

aws_region = "ap-northeast-1"
aws_azs = [
  "a",
  "c"
]

aws_vpc_cidr = "10.12.16.0/21"
aws_subnets_public = [ "10.12.20.0/23", "10.12.22.0/23" ]
aws_subnets_private = [ "10.12.16.0/23", "10.12.18.0/23" ]

# set to `true` to enable Route53 setup

enable_route53 = true
domain_name = "dojoalpha.com"

enable_email = true
sandbox_emails = [ ]
internal_emails = [ ]

# save the costs

elasticsearch_version = "7.1"
docdb_version  = "4.0"
instance_type = "c5.xlarge"
mysql_instance = "db.m5.large"
docdb_instance = "db.r5.large"
elasticsearch_instance_type = "m5.large.elasticsearch"
memcached_instance = "cache.m4.large"
redis_instance = "cache.m4.large"

