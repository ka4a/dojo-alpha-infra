# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
  provider "aws" {
    region = "ap-northeast-1"
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