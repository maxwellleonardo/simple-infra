resource "aws_s3_bucket" "codebuild-cache" {
  bucket = "simple-codebuild-cache-${random_string.random.result}"
  acl    = "private"

  lifecycle_rule {
    id      = "clean-up"
    enabled = "true"

    expiration {
      days = 3
    }
  }
}

resource "aws_s3_bucket" "simple-artifacts" {
  bucket = "simple-artifacts-${random_string.random.result}"
  acl    = "private"

  lifecycle_rule {
    id      = "clean-up"
    enabled = "true"

    expiration {
      days = 3
    }
  }
}

resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
}
