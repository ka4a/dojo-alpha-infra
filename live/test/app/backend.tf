# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
terraform {
  backend "s3" {
    bucket         = "dojo-dx-test-tfstate"
    dynamodb_table = "dojo-dx-test-tflock"
    encrypt        = true
    key            = "app/terraform.tfstate"
    region         = "ap-northeast-1"
  }
}
