include {
  path = find_in_parent_folders()
}
terraform {
  extra_arguments "common_vars" {
    commands = ["plan", "apply"]

    arguments = [
      "-var-file=../common.tfvars"
    ]
  }
}

dependency "infra" {
  config_path = "../infra"
}
inputs = {
  instance_profile = dependency.infra.outputs.openedx_instance_profile
  security_group_ig = dependency.infra.outputs.openedx_app_sg_id
  vpc_private_subnet_ids = dependency.infra.outputs.vpc_private_subnet_ids
  edxapp_lb_target_group_arn = dependency.infra.outputs.edxapp_lb_target_group_arn
}
