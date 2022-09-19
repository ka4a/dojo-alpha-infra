resource "aws_vpc" "vpc" {
  
  cidr_block       = var.vpc_cidr
  lifecycle {
    ignore_changes = [tags]
  }
  tags = merge(
    var.common_tags,
    {
      Name = "${var.customer_name}-${var.environment}"
    }
  )
}

resource "aws_subnet" "private_subnets" {
  vpc_id = aws_vpc.vpc.id
  count = length(var.azs)
  cidr_block = element(var.subnets_private, count.index)
  availability_zone = "${var.region}${element(var.azs , count.index)}"
  lifecycle {
    ignore_changes = [tags]
  }
  tags = merge(
    var.common_tags,
    {
      Name = "private-net-${count.index+1}-${var.customer_name}-${var.environment}"
      "aws-cdk:subnet-type" = "Private"
    }
  )
}

resource "aws_subnet" "public_subnets" {
  vpc_id = aws_vpc.vpc.id
  count = length(var.azs)
  cidr_block = element(var.subnets_public, count.index)
  availability_zone = "${var.region}${element(var.azs , count.index)}"
  lifecycle {
    ignore_changes = [tags]
  }
  tags = merge(
    var.common_tags,
    {
      Name = "public-net-${count.index+1}-${var.customer_name}-${var.environment}"
      "aws-cdk:subnet-type" = "Public"
    }
  )
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  lifecycle {
    ignore_changes = [tags]
  }
  tags = merge(
    var.common_tags,
    {
      Name = "igw-${var.customer_name}-${var.environment}"
    }
  )
}

resource "aws_route_table" "public_rtable" {
  vpc_id = aws_vpc.vpc.id
  lifecycle {
    ignore_changes = [tags]
  }
  tags = merge(
    var.common_tags,
    {
      Name = "public-${var.customer_name}-${var.environment}-rtable"
    }
  )
}

resource "aws_route" "public_subnet_default-route" {
  route_table_id            = aws_route_table.public_rtable.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_subnet_association" {
  count          = length(var.subnets_public)
  subnet_id      = element(aws_subnet.public_subnets.*.id , count.index)
  route_table_id = aws_route_table.public_rtable.id
}

resource "aws_eip" "nat_eip" {
  count = length(var.azs)
  vpc   = true
  lifecycle {
    ignore_changes = [tags]
  }
  tags = merge(
    var.common_tags,
    {
      Name = "eip-${count.index+1}-${var.customer_name}-${var.environment}"
    }
  )
}

resource "aws_nat_gateway" "nat_gateway" {
  count = length(var.azs)
  allocation_id = element(aws_eip.nat_eip.*.id , count.index)
  subnet_id     = element(aws_subnet.public_subnets.*.id , count.index)
  lifecycle {
    ignore_changes = [tags]
  }
  tags = merge(
    var.common_tags,
    {
      Name = "nat-gw-${count.index+1}-${var.customer_name}-${var.environment}"
    }
  )
}

resource "aws_route_table" "private_rtable" {
  vpc_id = aws_vpc.vpc.id
  count = length(var.azs)
  lifecycle {
    ignore_changes = [tags]
  }
  tags = merge(
    var.common_tags,
    {
      Name = "private-${var.customer_name}-${var.environment}-rtable-${count.index+1}"
    }
  )
}

resource "aws_route" "private_subnet_default-route" {
  count = length(var.azs)
  route_table_id         = element(aws_route_table.private_rtable.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat_gateway.*.id , count.index)
}

resource "aws_route_table_association" "private_subnet_association" {
  count = length(var.azs)
  subnet_id      = element(aws_subnet.private_subnets.*.id , count.index)
  route_table_id = element(aws_route_table.private_rtable.*.id, count.index)
}

