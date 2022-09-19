variable "environment" {
  type = string
  description = "PKR_VAR_environment: must be defined in GitHub Actions workflow environment"
}

variable "region" {
  type    = string
  description = "PKR_VAR_region: must be defined in GitHub Actions workflow environment"
}

variable "source_ami_name" {
  type    = string
  description = "PKR_VAR_source_ami_name: must be defined in GitHub Actions workflow environment"
}

variable "source_ami_owner" {
  type    = string
  description = "PKR_VAR_source_ami_owner: must be defined in GitHub Actions workflow environment"
}

variable "packer_security_group_id" {
  type    = string
  description = "PKR_VAR_packer_security_group_id: must be defined in GitHub Actions workflow environment"
}

variable "packer_network_id" {
  type    = string
  description = "PKR_VAR_packer_network_id: must be defined in GitHub Actions workflow environment"
}

locals {
  date_time = formatdate("YYYY-MM-DD-hh-mm", timestamp())
  ami_name  = "dojoalpha-${var.environment}-${local.date_time}"
}

# https://www.packer.io/docs/builders/amazon/ebs

source "amazon-ebs" "openedx" {
  ami_name               = "${local.ami_name}"
  spot_instance_types    = [ "t3.xlarge", "t2.xlarge", "m5.xlarge", "c5.xlarge" ]
  spot_price             = "auto"
  region                 = "${var.region}"

  subnet_filter {
    filters = {
          "tag:aws-cdk:subnet-type": "Private"
          "tag:environment": "${var.environment}"
    }
    most_free = true
    random = false
  }

  source_ami_filter {
    filters = {
      name                = "${var.source_ami_name}"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["${var.source_ami_owner}"]
  }

  launch_block_device_mappings {
    device_name = "/dev/sda1"
    volume_size = 40
    volume_type = "gp2"
    delete_on_termination = true
  }

  tags = {
    "Name" = "dojo-dx-edxapp"
    "created_by" = "GitHub Actions"
  }

  run_tags = {
    "Name" = "Packer Builder"
    "created_by" = "GitHub Actions"
    "developer" = "Reustle LLC"
    "warning" = "If this instance is long-running, then the packer build was failed. Instance can be safely terminated"
  }

  security_group_id = "${var.packer_security_group_id}"
  subnet_id = "${var.packer_network_id}"
  
  # created by terraform
  iam_instance_profile = "dojo-dx-${var.environment}-edxapp"
  associate_public_ip_address = false
  # https://www.packer.io/docs/builders/amazon/ebs#session-manager-connections
  ssh_interface = "session_manager"
  ssh_username = "ubuntu"
}

# a build block invokes sources and runs provisioning steps on them.
build {
  sources = ["source.amazon-ebs.openedx"]
  
  provisioner "file" {
    destination = "~/"
    sources = [
      "config_${var.environment}.yml",
      "config_${var.environment}_tf.yml",
      "config_${var.environment}.vault",
      "config_common.yml",
      "openedx_provision.sh",
      "openedx_ansible.vaultpass",
      "openedx_ansible.yaml",

      "openedx_ansible_celerybeat.yaml",
      "openedx_ansible_celerybeat_supervisor_conf.j2",
      "openedx_ansible_cloudwatch_agent.yaml",
      "openedx_ansible_cloudwatch_agent_config.j2",
      "openedx_ansible_cron_jobs.sh",
      "openedx_ansible_init_mongo.yaml",
      "openedx_ansible_init_mysql.yaml",
      "openedx_ansible_nginx_http_proxy.j2",
      "openedx_ansible_nginx_s3gateway_js.j2",
      "openedx_ansible_post_tasks.yaml",
      "openedx_ansible_pre_tasks.yaml",
      "openedx_ansible_contentstore_mongo_ROOT.patch",
      "openedx_ansible_mfe_speedup.patch",
      "openedx_ansible_edxapp_speedup.patch",
      "openedx_ansible_lti_producer.yaml"
    ]
  }
  provisioner "shell" {
    environment_vars = [
      "OPENEDX_RELEASE=open-release/maple.3",
      "ENVIRONMENT=${var.environment}",
      "ANSIBLE_VAULT_PASSWORD_FILE=~/openedx_ansible.vaultpass",
      "AMI_NAME=${local.ami_name}"
    ]
    inline = [ "./openedx_provision.sh" ]
  }
  post-processor "manifest" {
    output = "packer-manifest.json"
    strip_path = true
  }
}
