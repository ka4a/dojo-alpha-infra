output "edxapp_security_group_id" {
  value = aws_security_group.edxapp.id
}
output "packer_security_group_id" {
  value = aws_security_group.packer.id
}
output "edxapp_instance_profile" {
  value = aws_iam_instance_profile.edxapp.name
}
output "edxapp_lb_target_group_arn" {
  value = aws_lb_target_group.edxapp.arn
}
