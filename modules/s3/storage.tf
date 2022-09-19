data aws_iam_policy_document edxapp_s3_full_access {
  version = "2012-10-17"
  statement {
    actions = [
      "s3:*",
    ]
    effect = "Allow"

    resources = [
      aws_s3_bucket.edxapp.arn,
      "${aws_s3_bucket.edxapp.arn}/*",
    ]
  }
}

resource aws_s3_bucket edxapp {
  bucket = "${var.customer_name}-${var.environment}-edxapp-storage"
  acl = "private"
  server_side_encryption_configuration {
   rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
      }
    }
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "GET"]
    allowed_origins = ["*"]
  }
}

resource "aws_s3_bucket_public_access_block" backups_access_block {
  bucket = aws_s3_bucket.edxapp.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_iam_policy" "edxapp_s3_full_access" {
  name        = "${var.customer_name}-${var.environment}-edxapp-s3-full-access"
  description = "Grants full access to s3 resources in the ${aws_s3_bucket.edxapp.id} bucket"

  policy = data.aws_iam_policy_document.edxapp_s3_full_access.json
}

resource aws_iam_user edxapp_s3_user {
  name = "${var.customer_name}-${var.environment}-edxapp-s3"
}

resource aws_iam_user_policy_attachment edxapp_s3_full_access {
  policy_arn = aws_iam_policy.edxapp_s3_full_access.arn
  user = aws_iam_user.edxapp_s3_user.name
}

resource aws_iam_access_key edxapp_s3_access_key {
  user = aws_iam_user.edxapp_s3_user.name
}
