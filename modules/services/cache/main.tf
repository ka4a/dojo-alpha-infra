data "aws_vpc" "selected" {
  id = var.vpc_id
}

resource aws_elasticache_cluster redis {
  cluster_id = "edx-${var.customer_name}-${var.environment}-redis-cluster"
  engine = "redis"
  node_type = var.redis_node_type
  num_cache_nodes = 1   # redis doesn't support multiple nodes
  parameter_group_name = var.redis_parameter_group_name
  subnet_group_name = aws_elasticache_subnet_group.vpc_subnet_group.name
  security_group_ids = [aws_security_group.cache.id]
  port = var.redis_port
  snapshot_retention_limit = 1

  tags = merge(
    var.common_tags,
    {
      Name = "redis-${var.customer_name}-${var.environment}"
    }
  )
}

resource aws_elasticache_cluster memcached {
  cluster_id = "edx-${var.customer_name}-${var.environment}-memcached-cluster"
  engine = "memcached"
  engine_version = var.memcached_engine_version
  node_type = var.memcached_node_type
  num_cache_nodes = var.memcached_num_cache_nodes
  parameter_group_name = var.memcached_parameter_group_name
  subnet_group_name = aws_elasticache_subnet_group.vpc_subnet_group.name
  security_group_ids = [aws_security_group.cache.id]
  port = var.memcached_port

  tags = merge(
    var.common_tags,
    {
      Name = "memcached-${var.customer_name}-${var.environment}"
    }
  )
}

resource aws_elasticache_subnet_group vpc_subnet_group {
  name       = "${var.customer_name}-${var.environment}-cache-subnet"
  subnet_ids = var.private_net_ids

}

resource aws_security_group cache {
  name = "${var.customer_name}-${var.environment}-edxapp-cache"
  vpc_id = var.vpc_id

  tags = merge(
    var.common_tags,
    {
      Name = "cache-${var.customer_name}-${var.environment}"
    }
  )
}

resource aws_security_group_rule redis-outbound-rule {
  security_group_id = aws_security_group.cache.id
  type = "egress"
  protocol = "all"
  cidr_blocks = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]

  from_port = 0
  to_port = 0
}

resource aws_security_group_rule redis-inbound-rule-edxapp {
  type = "ingress"
  security_group_id = aws_security_group.cache.id
  source_security_group_id = var.edxapp_security_group_id

  protocol = "all"
  from_port = 6379
  to_port = 6379
}

resource aws_security_group_rule redis-inbound-rule-packer {
  type = "ingress"
  security_group_id = aws_security_group.cache.id
  source_security_group_id = var.packer_security_group_id

  protocol = "all"
  from_port = 6379
  to_port = 6379
}
