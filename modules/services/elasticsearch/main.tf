data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource aws_elasticsearch_domain "openedx" {
  domain_name = "${var.customer_name}-${var.environment}-elasticsearch"
  elasticsearch_version = var.elasticsearch_version
  node_to_node_encryption  { enabled = true }
  encrypt_at_rest  { enabled = true }
  #domain_endpoint_options {
  #enforce_https = true
  #tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  #}
  
  cluster_config {
    instance_count = 2
    instance_type = var.elasticsearch_instance_type
    zone_awareness_enabled = true

    dedicated_master_enabled = true
    dedicated_master_type = var.elasticsearch_instance_type
    dedicated_master_count = var.number_of_nodes

    zone_awareness_config {
      availability_zone_count = 2
    }
  }

  vpc_options {
    subnet_ids = var.private_net_ids
    security_group_ids = [aws_security_group.elasticsearch.id]
  }

  ebs_options {
    ebs_enabled = true
    volume_type = "gp2"
    volume_size = 10
  }

  access_policies = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "es:*",
      "Resource": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.customer_name}-${var.environment}-elasticsearch/*"
    }
  ]
}
POLICY

  depends_on = [aws_iam_service_linked_role.elasticsearch]

  tags = merge(
    var.common_tags,
    {
      Name = "es-${var.customer_name}-${var.environment}"
    }
  )
}

resource aws_iam_service_linked_role "elasticsearch" {
  # there can only be one
  #enabled = "false"
  count = var.create_iam_service_linked_role ? 1 : 0
  aws_service_name = "es.amazonaws.com"
  description      = "Allows Amazon ES to manage AWS resources for a domain on your behalf."

}

resource aws_security_group "elasticsearch" {
  name = "${var.customer_name}-${var.environment}-edxapp-elasticsearch"
  vpc_id = var.vpc_id

  tags = merge(
    var.common_tags,
    {
      Name = "es-${var.customer_name}-${var.environment}"
    }
  )
}

resource aws_security_group_rule "es-edxapp-inbound-packer-rule" {
  security_group_id = aws_security_group.elasticsearch.id
  source_security_group_id = var.packer_security_group_id
  type = "ingress"

  from_port = 80
  to_port = 80
  protocol = "tcp"
}

resource aws_security_group_rule "es-edxapp-inbound-rule" {
  security_group_id = aws_security_group.elasticsearch.id
  source_security_group_id = var.edxapp_security_group_id
  type = "ingress"

  from_port = 0
  to_port = 0
  protocol = "-1"
}

resource aws_security_group_rule "es-edxapp-inbound-own-rule" {
  security_group_id = aws_security_group.elasticsearch.id
  source_security_group_id = aws_security_group.elasticsearch.id
  type = "ingress"

  from_port = 0
  to_port = 0
  protocol = "-1"
}

resource aws_security_group_rule "es-edxapp-outbound-rule" {
  security_group_id = aws_security_group.elasticsearch.id
  type = "egress"

  from_port = 0
  to_port = 0
  protocol = "all"
  cidr_blocks = ["0.0.0.0/0"]
}
