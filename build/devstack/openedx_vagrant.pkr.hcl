source "vagrant" "openedx" {
  communicator = "ssh"
  #
  # please use this source_path on first run
  # source_path = "ubuntu/focal64"
  source_path = "packer_openedx"

  provider = "virtualbox"
  add_force = true
  template = "./openedx_vagrant.template"
}

# a build block invokes sources and runs provisioning steps on them.
build {
  sources = ["source.vagrant.openedx"]
  
  provisioner "file" {
    destination = "~/"
    source      = "../openedx_ansible.yaml"
  }
  provisioner "file" {
    destination = "~/"
    source      = "../openedx_provision.sh"
  }
  provisioner "file" {
    destination = "~/config.yml"
    source      = "./config_vagrant.yml"
  }
  provisioner "shell" {
    environment_vars = [ "OPENEDX_RELEASE=open-release/koa.3" ]
    inline = [ "./openedx_provision.sh" ]
  }
}
