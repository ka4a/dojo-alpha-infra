environment = "new_environment"
customer_name = "dojo-dx"

aws_region = "ap-northeast-1"
aws_azs = [
  "c",
  "d"
]

# set to `true` to enable Route53 setup

enable_route53 = false
domain_name = "new_environment.dojoalpha.com"

# set to `true` to enable setup of SES and records in Route53 zone

enable_email = false
sandbox_emails = [ ]
internal_emails = [ ]

# save the costs

# docdb_instance = "db.t3.medium"
# mysql_instance = "db.t3.small"
# redis_instance = "cache.t3.small"
# memcached_instance = "cache.t3.small"
# instance_type = "t3.large"
