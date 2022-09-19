locals {
  common_tags = {
    "created_by"  = "ReustleLLC",
    "environment" = "${var.environment}"
    "managed_by"  = "terraform"
  }
}
