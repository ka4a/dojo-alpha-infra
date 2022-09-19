data "aws_vpc" "selected" {
  id = var.vpc_id
}

# https://registry.terraform.io/modules/drpebcak/documentdb-cluster/aws/latest
module "documentdb-cluster" {
  source  = "drpebcak/documentdb-cluster/aws"
  version = "0.3.1"
  family = var.family
  engine_version = var.engine_version
  cluster_instance_class = var.cluster_instance_class
  group_subnets = var.private_net_ids
  cluster_security_group = [ aws_security_group.docdb.id ]
  master_password = var.mongo_password
  master_username = var.mongo_username
  name = "openedx-${var.customer_name}-${var.environment}"
  apply_immediately = true
  parameters = [
    {
      apply_method = "immediate"
      name         = "tls"
      value        = "disabled"
    }
 ]

}

resource aws_security_group docdb {
  name = "${var.customer_name}-${var.environment}-edxapp-docdb"
  vpc_id = var.vpc_id

  tags = merge(
    var.common_tags,
    {
      Name = "mongo-${var.customer_name}-${var.environment}"
    }
  )
}

resource aws_security_group_rule docdb-outbound-rule {
  security_group_id = aws_security_group.docdb.id
  type = "egress"
  protocol = "all"
  cidr_blocks = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]

  from_port = 0
  to_port = 0
}

resource aws_security_group_rule docdb-inbound-rule {
  type = "ingress"
  security_group_id = aws_security_group.docdb.id
  source_security_group_id = var.edxapp_security_group_id

  protocol = "tcp"
  from_port = 27017
  to_port = 27017
}

resource aws_security_group_rule docdb-inbound-rule-packer {
  type = "ingress"
  security_group_id = aws_security_group.docdb.id
  source_security_group_id = var.packer_security_group_id

  protocol = "tcp"
  from_port = 27017
  to_port = 27017
}
