module "vpc" {
  source = "../../../modules/vpc"

  customer_name = var.customer_name
  environment   = var.environment
  region        = var.aws_region
  azs           = var.aws_azs

  common_tags   = local.common_tags
}

module "route53" {
  source = "../../../modules/route53"
  customer_domain = var.domain_name

  count = "${var.enable_route53 ? 1 : 0}"
}

module "email" {
  source                  = "../../../modules/email"
  customer_domain         = var.domain_name
  custom_emails_to_verify = var.sandbox_emails
  internal_emails         = var.internal_emails
  route53_id              = "${var.enable_route53 ? module.route53.route53_id : var.enable_route53}"

  customer_name = var.customer_name
  environment   = var.environment

  count = "${var.enable_email ? 1 : 0}"
}

module "s3" {
  source        = "../../../modules/s3"
  customer_name = var.customer_name
  environment   = var.environment

  common_tags   = local.common_tags
}

module "openedx" {
  source           = "../../../modules/services/openedx"
  vpc_id           = module.vpc.vpc_id    
  customer_name    = var.customer_name
  environment      = var.environment
  customer_domain  = var.domain_name
  private_net_cidr_blocks = module.vpc.private_cidr_blocks
  private_net_ids  = module.vpc.private_subnet_ids
  public_net_ids   = module.vpc.public_subnet_ids
  enable_route53   = var.enable_route53

  common_tags   = local.common_tags
}

# Dbs

module "sql" {
  source = "../../../modules/services/sql"

  customer_name = var.customer_name
  environment = var.environment

  engine_version = var.mysql_engine_ver
  allocated_storage = var.mysql_storage_size
  database_root_username = "edxadmin"
  database_root_password = var.mysql_password
  vpc_id                 = module.vpc.vpc_id
  private_net_ids        = module.vpc.private_subnet_ids

  edxapp_security_group_id = module.openedx.edxapp_security_group_id
  packer_security_group_id = module.openedx.packer_security_group_id

  instance_class = var.mysql_instance

  common_tags   = local.common_tags
}

module "elasticsearch" {
  source = "../../../modules/services/elasticsearch"
  customer_name = var.customer_name
  vpc_id = module.vpc.vpc_id
  private_net_ids = module.vpc.private_subnet_ids
  edxapp_security_group_id = module.openedx.edxapp_security_group_id
  packer_security_group_id = module.openedx.packer_security_group_id
  environment = var.environment

  common_tags   = local.common_tags
}

module "cache" {
  source = "../../../modules/services/cache"
  vpc_id = module.vpc.vpc_id
  private_net_ids = module.vpc.private_subnet_ids
  customer_name = var.customer_name
  environment = var.environment
  redis_node_type = var.redis_instance
  memcached_node_type = var.memcached_instance
  edxapp_security_group_id = module.openedx.edxapp_security_group_id
  packer_security_group_id = module.openedx.packer_security_group_id

  common_tags   = local.common_tags
}

module "docdb" {
  source = "../../../modules/services/docdb"
  vpc_id = module.vpc.vpc_id
  private_net_ids = module.vpc.private_subnet_ids
  customer_name = var.customer_name
  environment = var.environment
  mongo_username = "edxadmin"
  mongo_password = var.mysql_password
  cluster_instance_class = var.docdb_instance
  edxapp_security_group_id = module.openedx.edxapp_security_group_id
  packer_security_group_id = module.openedx.packer_security_group_id

  common_tags   = local.common_tags
}
