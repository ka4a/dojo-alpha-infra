locals {
  aws_region = "ap-northeast-1"
  environment = "prod"
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
    ignore_tags {
       keys = [
         "woven:created:at",
         "woven:created:by",
         "woven:app",
         "woven:deployment",
         "woven:env",
         "woven:org-code"
       ]
     }
  }
EOF
}

generate "versions" {
  path      = "versions_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    terraform {
      required_providers {
        aws = {
          source  = "hashicorp/aws"
          version = "~> 3.63"
        }
      }
    }
EOF
}