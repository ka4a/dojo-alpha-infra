resource "aws_instance" "edxapp" {
  ami                    = var.app_instance_image_id
  instance_type          = var.instance_type
  subnet_id              = element(var.vpc_private_subnet_ids, 1)
  vpc_security_group_ids = [var.security_group_ig]

  root_block_device {
    volume_size = 50
    volume_type = "gp2"
    encrypted = true
  }

  iam_instance_profile = var.instance_profile

  tags = {
    "Name"       = "edxapp-${var.environment}"
    "created_by" = "GitHub Actions"
    "developer"  = "Reustle LLC"
  }

  lifecycle {
    ignore_changes = [tags]
    create_before_destroy = true
  }

  # delay for django warmup
  provisioner "local-exec" {
    command = "sleep 180"
  }
}

resource "aws_lb_target_group_attachment" "edxapp" {
  target_group_arn = var.edxapp_lb_target_group_arn
  target_id        = aws_instance.edxapp.id
  port             = 80

  depends_on = [ aws_instance.edxapp ]

  lifecycle {
    create_before_destroy = true
  }
}
