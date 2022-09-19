# Dojo Alpha - Infrastructure as Code

**Deployements:**
- [![PROD deploy](https://github.com/reustleco/dojo-alpha-infra/actions/workflows/deploy-prod.yml/badge.svg)](https://github.com/reustleco/dojo-alpha-infra/actions/workflows/deploy-prod.yml)
- [![EXP deploy](https://github.com/reustleco/dojo-alpha-infra/actions/workflows/deploy-exp.yml/badge.svg)](https://github.com/reustleco/dojo-alpha-infra/actions/workflows/deploy-exp.yml)
- [![DEV deploy](https://github.com/reustleco/dojo-alpha-infra/actions/workflows/deploy-dev.yml/badge.svg)](https://github.com/reustleco/dojo-alpha-infra/actions/workflows/deploy-dev.yml)
- [![TEST deploy](https://github.com/reustleco/dojo-alpha-infra/actions/workflows/deploy-test.yml/badge.svg)](https://github.com/reustleco/dojo-alpha-infra/actions/workflows/deploy-test.yml)

This project is designed to create multi-stage `Open edX` deployment, to perform deployment
steps follow the information below. 

## Requirements

- terraform = v0.14.11
- terragrunt = v0.28.24
- packer = 1.7.0

This configuration uses standard [terragrunt layout](https://terragrunt.gruntwork.io/docs/getting-started/quick-start/#promote-immutable-versioned-terraform-modules-across-environments)
for terraform files.

## AWS account prerequisites 

It is desirable that the Amazon AWS IAM account used for infrastructure deployment and application
build be an administrator type (AdministratorAccess, IAMUserChangePassword IAM policies attached).

If this is not possible please request a full access to this resources in project's region:

- VPC
- EC2
- Route53
- SES
- S3
- DocDB
- RDS
- Elasticsearch
- ElastiCache (Memcached, Redis)

# GitHub Actions

NOTE: GitHub Actions workflow does not run `terragrunt apply` command for infra to prevent
      unwanted infrastructure changes.
      GitHub Actions workflow run `terragrunt plan` and fails if changes where deteceted.
      Fixes to get AWS resources and terragrunt code synchronized must be applied manually.

## First deploy

Very first deployment of infrastructure for specific environment must be performed manually
(see [How to create new environment](#how-to-create-new-environment)).

## Workflow

- infra: `terragrunt plan` - detects infrastructure changes. If terraform code or AWS resources
  changes detected the workflow will fail with warning.
- prepare environment variables for packer build from `terragrunt output`.
- start packer build.
- catch AMI ID from packer output.
- app: `terragrunt apply` - deploy VM with new AMI.

## GitHub Actions secrets

- `ANSIBLE_VAULT_PASSWORD` - ansible-vault password for encrypted vaults (all environments).
- `EDXAPP_STAFF_PASSWORD` - password for master edxapp staff account (all environments).
                            Also used as RDS and DocDB admin user password.
- `DEV_AWS_DEFAULT_REGION`, `DEV_AWS_ACCESS_KEY_ID`, `DEV_AWS_SECRET_ACCESS_KEY`, `DEV_VPC_ID` - AWS credentials for DEV environment.
- `STAGE_AWS_DEFAULT_REGION`, `STAGE_AWS_ACCESS_KEY_ID`, `STAGE_AWS_SECRET_ACCESS_KEY`, `STAGE_VPC_ID` - AWS credentials for STAGE environment.
- `PROD_AWS_DEFAULT_REGION`, `PROD_AWS_ACCESS_KEY_ID`, `PROD_AWS_SECRET_ACCESS_KEY`, `PROD_VPC_ID` - AWS credentials for PROD environment.

NOTE: AWS credentials can be merged if single account is used (changes must be reflected in GitHub Actions workflow)

## GitHub Actions local debugging

Docker Desktop must be installed on local machine to able to run `act` tool.

```
# install act tool https://github.com/nektos/act
brew install act

cat > act.secrets <<EOF
# variables from repository secrets
EDXAPP_STAFF_PASSWORD=...
ANSIBLE_VAULT_PASSWORD=...
DEV_AWS_DEFAULT_REGION=...
DEV_AWS_ACCESS_KEY_ID=...
DEV_AWS_SECRET_ACCESS_KEY=...
# developer github account personal token (used for git clone)
GITHUB_TOKEN=...
EOF

act --reuse --secret-file act.secrets

```

Debugging execution flow in case of issues. `act` tool does not stop a service docker container
when workflow fails. This container can be used for debugging:

```
docker cp act.secrets act-STAGE-deploy-build:/tmp/act.secrets
docker exec -it act-STAGE-deploy-build bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/hostedtoolcache/terragrunt/0.28.24/x64:/tmp/c4eb5139-53ab-457b-b79f-81a5f4259604
export TERRAFORM_CLI_PATH=/tmp/c4eb5139-53ab-457b-b79f-81a5f4259604
. /tmp/act.secrets

cd ${GITHUB_WORKSPACE}/live/${ENVIRONMENT}/infra
tarragrunt show

cd ${GITHUB_WORKSPACE}/build
packer build openedx.pkr.hcl 
```

# Manual run

NOTE: terragrunt/terraform and packer code designed to run in GitHub Actions workflow
      (please refer [GitHub Actions secrets](#github-actions))

## Prepare shell to run terragrunt/terraform or packer locally

All variables from GitHub Actions workflow must be defined in current terminal shell:
```
export AWS_DEFAULT_REGION=...
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export ANSIBLE_VAULT_PASSWORD=...
export ENVIRONMENT=...
export EDXAPP_STAFF_PASSWORD=...
```

## Terragrunt manual run for infra setup or reconfiguration

```
export TF_VAR_environment=<dev|stage|prod>
export TF_VAR_mysql_password=${EDXAPP_STAFF_PASSWORD}
export TF_VAR_mongo_password=${EDXAPP_STAFF_PASSWORD}

cd live/${TF_VAR_environment}/infa
terragrunt init           # only on first run
terragrunt plan
terragrunt apply
```

If Route53 service has predefined DNS zone, then it must be imported into terraform state first.
One need to find Route53 zone ID in AWS console interface (`Z0XXXXXXXXXXXXXXXXXXX`).

```
cd live/${TF_VAR_environment}/infa
terraform state rm module.route53.aws_route53_zone.primary
export TF_VAR_mysql_password="${EDXAPP_STAFF_PASSWORD}"
export TF_VAR_mongo_password="${EDXAPP_STAFF_PASSWORD}"
terraform import -var-file=../common.tfvars module.route53.aws_route53_zone.primary Z0XXXXXXXXXXXXXXXXXXX
```

At the end of resource creation, terraform will provide output values that will be used in
the application build process. 

Output example:
```
elasticsearch_endpoint = "vpc-dojo-stage-elasticsearch-qgl2kjlrz26zi4rrkjsgdgmbuu.ap-northeast-1.es.amazonaws.com"
openedx_app_sg_id = "sg-01370888b707e84d4"
openedx_instance_profile = "dojo-stage-edxapp"
openedx_s3_storage_access_key = "MASKED"
openedx_s3_storage_access_secret = "MASKED"
openedx_s3_storage_bucket_name = "dojo-stage-edxapp-storage"
openedx_s3_tracking_logs_access_key = "MASKED"
openedx_s3_tracking_logs_access_secret = "MASKED"
openedx_s3_tracking_logs_bucket_name = "dojo-stage-edxapp-tracking-logs"
rds_host_name = "dojo-stage-openedx.cj6zgnhetdef.ap-northeast-1.rds.amazonaws.com:3306"
vpc_id = "vpc-0200b6c8e20a2c0d1"
vpc_private_subnet_ids = tolist([
  "subnet-0130428be0b816344",
  "subnet-022b35b21038a55f8",
])
```

## Packer manual run

Prepare config file with ansible variable overrides which must be extracted from terraform output (please refer [the CI
flow](.github/workflows/deploy-dev.yml#L57) to get actual list of required variables):

```
export TF_VAR_environment=<dev|stage|prod>

cd live/${TF_VAR_environment}/infa
ANSIBLE_TF_CONFIG_TMP="../../../build/config_${TF_VAR_environment}_tf.yml"
echo "EDXAPP_STAFF_PASSWORD: ${EDXAPP_STAFF_PASSWORD}" > ${ANSIBLE_TF_CONFIG_TMP}
echo "EDXAPP_AWS_STORAGE_BUCKET_NAME: "$(terragrunt output -raw openedx_s3_storage_bucket_name) >> ${ANSIBLE_TF_CONFIG_TMP}
echo "EDXAPP_AWS_ACCESS_KEY_ID: "$(terragrunt output -raw openedx_s3_storage_access_key) >> ${ANSIBLE_TF_CONFIG_TMP}
echo "EDXAPP_AWS_SECRET_ACCESS_KEY: "$(terragrunt output -raw openedx_s3_storage_access_secret) >> ${ANSIBLE_TF_CONFIG_TMP}
echo "AWS_S3_LOGS_ACCESS_KEY_ID: "$(terragrunt output -raw openedx_s3_tracking_logs_access_key) >> ${ANSIBLE_TF_CONFIG_TMP}
echo "AWS_S3_LOGS_SECRET_KEY: "$(terragrunt output -raw openedx_s3_tracking_logs_access_secret) >> ${ANSIBLE_TF_CONFIG_TMP}
echo "COMMON_OBJECT_STORE_LOG_SYNC_BUCKET: "$(terragrunt output -raw openedx_s3_tracking_logs_bucket_name) >> ${ANSIBLE_TF_CONFIG_TMP}
echo "ELASTICSEARCH_HOST: "$(terragrunt output -raw elasticsearch_endpoint) >> ${ANSIBLE_TF_CONFIG_TMP}
echo "MEMCACHE_ENDPOINT: "$(terragrunt output -raw memcached_endpoint) >> ${ANSIBLE_TF_CONFIG_TMP}
echo "EDXAPP_REDIS_HOSTNAME: "$(terragrunt output -raw redis_endpoint) >> ${ANSIBLE_TF_CONFIG_TMP}
echo "EDXAPP_MYSQL_HOST: "$(terragrunt output -raw rds_host_name | cut -f 1 -d :) >> ${ANSIBLE_TF_CONFIG_TMP}
echo "MYSQL_ADMIN_USER: "$(terragrunt output -raw rds_user) >> ${ANSIBLE_TF_CONFIG_TMP}
echo "MYSQL_ADMIN_PASSWORD: "$(terragrunt output -raw rds_password) >> ${ANSIBLE_TF_CONFIG_TMP}
echo "EDXAPP_MONGO_HOSTS: "$(terragrunt output -raw mongo_endpoint) >> ${ANSIBLE_TF_CONFIG_TMP}
echo "MONGO_ADMIN_USER: "$(terragrunt output -raw mongo_user) >> ${ANSIBLE_TF_CONFIG_TMP}
echo "MONGO_ADMIN_PASSWORD: "$(terragrunt output -raw mongo_password) >> ${ANSIBLE_TF_CONFIG_TMP}
echo "COMMON_STAFF_PASSWORD: "${EDXAPP_STAFF_PASSWORD} >> ${ANSIBLE_TF_CONFIG_TMP}
export PKR_VAR_packer_security_group_id=$(terragrunt output -raw packer_sg_id)
export PKR_VAR_environment=${TF_VAR_environment}
export PKR_VAR_region=ap-northeast-1
export PKR_VAR_source_ami_name="openedx-dev-*" # "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*" for clear Ubuntu AMI
export PKR_VAR_source_ami_owner="366401772994" # "099720109477" for clear Ubuntu AMI

cd ../../../build/
packer build openedx.pkr.hcl
```

# How to create new environment

AWS infrastructure preparation and very first deployment must be completed manually by
executing terragrunt, packer build and setup of all required variables in configuration files.

1. Prepare new terragrunt enviroment.

  - Clone this repository to local computer.

  - Create new `live` directory from template

  ```
  cp -Rap terragrunt_env_template live/new_environmet
  ```

  - Edit `new_environmet/common.tfvars`. Set `environment` variable as environment name,
      set `region` variable as project's AWS region name.

  - Edit `new_environmet/terragrunt.hcl`. Set `environment` and `region` variables.

2. [Prepare shell to run terragrunt/terraform or packer locally](#prepare-shell-to-run-terragruntterraform-or-packer-locally).

3. Infrastructure preparation.

  - Code in this repository expect clean AWS account. No predefined VPC, subnetworks, DocDB,
      RDP or EC2 resources expected.

    - (For advanced users) If any project related resources already exists in AWS account,
           edit `common.tfvars` set all variables according to
           existing resources, init terraform state and [import](https://www.terraform.io/docs/cli/import/usage.html)
           all existing resources to terraform state.

  - Edit `new_environmet/common.tfvars`. Make sure that `azs` variable contains two AZ's which
      available in selected for project AWS region. To get all AZ's available in selected region
      execute this command - `aws ec2 describe-availability-zones --region ap-northeast-1`.

4. Import existing or order new SSL certificate for `domain_name` and `*.{domain_name}` in AWS ESM.

5. Setup infrastructure.

```
cd new_environmet/infra
terragrunt init
# make sure that output of `terragrunt plan` command contains no errors, resource
# destruction or change attempts
terragrunt plan
export TF_VAR_mysql_password="${EDXAPP_STAFF_PASSWORD}"
export TF_VAR_mongo_password="${EDXAPP_STAFF_PASSWORD}"
terragrunt apply
```

6. Prepare GitHub action flow for new environment.

  - Create new GHA flow config.

    ```
    cp .github/workflows/deploy-dev.yml .github/workflows/deploy-new_environmet.yml
    ```

  - Edit `.github/workflows/deploy-new_environmet.yml` set the value of ENVIRONMENT variable
      to name of `new_environment`. Change the `name:` of flow to descriptive text for
      `new_environment`.

7. Prepare OpenEdx deployment configuration.

  - [Install ansible package](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-specific-operating-systems).
    Mac users can install via `brew install ansible`.

    ```
    cd build
    cp config.yml.example config_new_environment.yml
    cp config.vault.example config_new_environment.vault
    ```

  - Edit `config_new_environment.yml` file with new OpenEdx configuration (or copy
    variables from existing configuration).

  - Edit `must be changed manually` section of `config_new_environment.vault` file.
  
  - Generate new internal services credentials by changing `XXXXX` values to random
      alpha-numeric symbols. 
      Can be quickly changed with Perl by issuing this command - 
      `perl -pi -e 's/(XXX+)/join "", map { ("a" .. "z", "A" .. "Z", 0 .. 9)[rand(62)] } 1 .. length($1)/eg' config_new_environment.vault`
  
  - Encrypt `config_new_environment.vault` file using `ansible_vault` tool and password
      saved as GitHub secret `ANSIBLE_VAULT_PASSWORD`.

      ```
      ansible-vault encrypt config_new_environment.vault
      ```

  - Commit and create Pull Request to `master` branch with new GHA flow.

      ```
      git add .github/workflows/deploy-new_enviroment.yml build/config.vault.example build/config_new_enviroment.vault build/config_new_enviroment.yml
      git commit .github/workflows/deploy-new_enviroment.yml
      git push origin new_environment
      ```

  - Review and merge the PR.

  - Commit and push all changes to new branch.

    ```
    git add build/config.vault.example build/config_new_enviroment.vault build/config_new_enviroment.yml
    git commit build/config.vault.example build/config_new_enviroment.vault build/config_new_enviroment.yml
    git push origin new_environment
    ```

  - Add/verify that variables used in GitHub Actions flow is configured in GitHub repo secrets.

    ```
    AWS_DEFAULT_REGION
    AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY
    EDXAPP_STAFF_PASSWORD
    ANSIBLE_VAULT_PASSWORD
    ```

  - Trigger new workflow on new branch to deploy app instance.

  - Test new deployment.

  - If test is successful change packer build source to use AMI created on previous step as deployment source (to speed up build time).

  - Review repository changes and merge them to `master` branch.

8. (Optional) To speed up building of OpenEdx application (packer build) GitHub Actions
   flow variables `PKR_VAR_source_ami_name` and `PKR_VAR_source_ami_owner` can be set to
   point to AMI from previous build. This will reduce an ansible deployment tasks time
   significantly.
