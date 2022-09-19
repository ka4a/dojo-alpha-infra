output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "private_cidr_blocks" {
  value = [ for s in aws_subnet.private_subnets : s.cidr_block ]
}

output "public_cidr_blocks" {
  value = [ for s in aws_subnet.public_subnets : s.cidr_block ]
}

output "private_subnet_ids" {
  value = tolist(aws_subnet.private_subnets.*.id)
}

output "public_subnet_ids" {
  value = tolist(aws_subnet.public_subnets.*.id)
}
