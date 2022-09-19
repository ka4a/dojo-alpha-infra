Packer build configuration
==========================

Prepares AWS AMI image with OpenEdx edxapp service and edxapp celery workers.

Prerequisites
-------------

- [Session Manager plugin for the WS CLI](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html) installed
- [terragrund infra](../live/stage/infra) component provisioned (see [README](../README.md))
- `app_security_group_id` set to id of NSG created by terraform
- `config.yml` created from config.yml.example
  * replace XXXXXXX values with random strings `perl -pi -e 's/(XXX+)/join "", map { ("a" .. "z", "A" .. "Z", 0 .. 9)[rand(62)] } 1 .. length($1)/eg' config.yml`
  * replace services endpoints and AWS S3 credentials using terrafrom output for infra `terraform show -json | qt`
  * replace `MONGO_ADMIN_USER` and `MONGO_ADMIN_PASSWORD` with `mongo_user` and `mongo_password` values from [common.tfvars](../live/stage/common.tfvars)
  * replace `MYSQL_ADMIN_USER` and `MYSQL_ADMIN_PASSWORD` with `mysql_user` and `mysql_password` values from [common.tfvars](../live/stage/common.tfvars)
- AWS SES service mode need to be approved from `Sandbox` mode to `Production` (by request to AWS support)
- AWS SES verified e-mail `COMMON_DEFAULT_FROM_EMAIL`
- AWS SES SMTP credentials created and set into `COMMON_EMAIL_HOST_USER`, `COMMON_EMAIL_HOST_PASSWORD` variables

Image build
-----------

```
export AWS_ACCESS_KEY_ID=AKI...
export AWS_SECRET_ACCESS_KEY=YB6...
export AWS_DEFAULT_REGION=ap-northeast-1
packer build -var-file=openedx.auto.pkrvars.hcl openedx.pkr.hcl
```

Devstack (vagrant) development
==============================

Prerequisites
-------------

- VirtuabBox latest version
- vagrant latest version

Image build
-----------

Initial (first) build based on clean Ubuntu 20.04 image. To build the image very first time please change the `source_path` parameter to "ubuntu/focal64"` in [openedx_vagrant.pkr.hcl](openedx_vagrant.pkr.hcl) file, make build and change the `source_path` to "packer_openedx" to use already provisioned image as source. This will greatly reduce the build time!


```
packer build --force openedx_vargant.pkr.hcl
```

Running devstack
----------------

LMS URL - http://localhost:18000
CMS URL - http://localhost:18010

```
cd devstack
vagrant up
vagrant ssh
# do any changes you like as you do on live instance
vagrant halt
```
