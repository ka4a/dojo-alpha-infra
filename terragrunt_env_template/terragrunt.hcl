locals {
  aws_region = "ap-northeast-1"
  environment = "new_environment"
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = "dojo-dx-${local.environment}-tfstate"

    key = "${path_relative_to_include()}/terraform.tfstate"
    region         = "${local.aws_region}"
    encrypt        = true
    dynamodb_table = "dojo-dx-${local.environment}-tflock"
  }
}

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
  provider "aws" {
    region = "${local.aws_region}"
  }
EOF
}
