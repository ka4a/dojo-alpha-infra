# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
terraform {
  backend "s3" {
    bucket         = "dojo-dx-prod-tfstate"
    dynamodb_table = "dojo-dx-prod-tflock"
    encrypt        = true
    key            = "./terraform.tfstate"
    region         = "ap-northeast-1"
  }
}
