resource aws_security_group packer {
  name = "${var.customer_name}-${var.environment}-packer"
  vpc_id = var.vpc_id
 }

# Disabled because of woven security rules.
// resource aws_security_group_rule packer_inbound_rule {
//   security_group_id = aws_security_group.packer.id
//   type = "ingress"

//   from_port = 22
//   to_port = 22
//   protocol = "tcp"
//   cidr_blocks = ["0.0.0.0/0"]
// }

resource aws_security_group_rule packer_outbound_rule {
  security_group_id = aws_security_group.packer.id
  type = "egress"

  from_port = 0
  to_port = 0
  protocol = "all"
  cidr_blocks = ["0.0.0.0/0"]
}

resource aws_security_group edxapp {
  name = "${var.customer_name}-${var.environment}-edxapp"
  vpc_id = var.vpc_id
 }

resource aws_security_group_rule edxapp-inbound-private {
  security_group_id = aws_security_group.edxapp.id
  type = "ingress"

  from_port = 0
  to_port = 0
  protocol = "all"
  cidr_blocks = var.private_net_cidr_blocks
}

resource aws_security_group_rule edxapp_inbound_rule {
  security_group_id = aws_security_group.edxapp.id
  type = "ingress"

  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource aws_security_group_rule edxapp_outbound_rule {
  security_group_id = aws_security_group.edxapp.id
  type = "egress"

  from_port = 0
  to_port = 0
  protocol = "all"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_iam_instance_profile" "edxapp" {
  name = "${var.customer_name}-${var.environment}-edxapp"
  role = aws_iam_role.main.name
}

resource "aws_iam_role" "main" {
  name               = "${var.customer_name}-${var.environment}-edxapp"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_server" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "edxapp_s3_storage" {
  role       = aws_iam_role.main.name
  policy_arn = var.s3_storage_policy_arn
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
