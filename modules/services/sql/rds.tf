data "aws_vpc" "selected" {
  id = var.vpc_id
}

resource aws_db_instance mysql_rds {
  identifier = "${var.customer_name}-${var.environment}-openedx"
  instance_class = var.instance_class
  engine = "mysql"
  engine_version = var.engine_version

  allocated_storage = var.allocated_storage
  storage_type = "gp2"
  skip_final_snapshot = var.skip_final_snapshot
  backup_retention_period = 14

  publicly_accessible = false
  storage_encrypted = true
  kms_key_id = aws_kms_key.rds_encryption.arn
  auto_minor_version_upgrade = false
  multi_az = var.enable_multi_az

  deletion_protection = false

  username = var.database_root_username
  password = var.database_root_password

  db_subnet_group_name = aws_db_subnet_group.primary.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  max_allocated_storage = var.max_allocated_storage

  tags = merge(
    var.common_tags,
    {
      Name = "rds-${var.customer_name}-${var.environment}"
    }
  )
}


## This is exactly the same as the master
resource aws_db_instance mysql_rds_replicas {
  count = var.number_of_replicas
  identifier = "${var.customer_name}-${var.environment}-openedx-replica-${count.index}"
  instance_class = var.instance_class
  engine_version = var.engine_version

  storage_type = "gp2"

  publicly_accessible = var.replica_publicly_accessible
  storage_encrypted = true
  kms_key_id = aws_kms_key.rds_encryption.arn
  auto_minor_version_upgrade = false
  multi_az = var.enable_replica_multi_az
  replicate_source_db = aws_db_instance.mysql_rds.identifier
  vpc_security_group_ids = var.replica_extra_security_group_ids

  skip_final_snapshot = true

  max_allocated_storage = var.max_allocated_storage
}

resource aws_kms_key rds_encryption {
  description = "KMS RDS Encryption"

  tags = merge(
    var.common_tags,
    {
      Name = "rds-${var.customer_name}-${var.environment}"
    }
  )
}

resource aws_db_subnet_group primary {
  name = "${var.customer_name}-${var.environment}-openedx"
  subnet_ids = var.private_net_ids

  tags = merge(
    var.common_tags,
    {
      Name = "rds-${var.customer_name}-${var.environment}"
    }
  )
}

resource aws_security_group rds {
  name = "${var.customer_name}-${var.environment}-edxapp-rds"
  vpc_id = var.vpc_id

  tags = merge(
    var.common_tags,
    {
      Name = "rds-${var.customer_name}-${var.environment}"
    }
  )
}

resource aws_security_group_rule rds-outbound-rule {
  security_group_id = aws_security_group.rds.id
  type = "egress"
  protocol = "all"
  cidr_blocks = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]

  from_port = 0
  to_port = 0
}

resource aws_security_group_rule rds-inbound-rule {
  type = "ingress"
  security_group_id = aws_security_group.rds.id
  source_security_group_id = var.edxapp_security_group_id

  protocol = "tcp"
  from_port = 3306
  to_port = 3306
}
resource aws_security_group_rule rds-inbound-rule-packer {
  type = "ingress"
  security_group_id = aws_security_group.rds.id
  source_security_group_id = var.packer_security_group_id

  protocol = "tcp"
  from_port = 3306
  to_port = 3306
}
