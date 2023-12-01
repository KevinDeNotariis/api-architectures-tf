# ------------------------------------------------------------------------------------------
# Create an S3 bucket where to store the Lambda source codes
# ------------------------------------------------------------------------------------------
resource "aws_s3_bucket" "lambdas_source_code" {
  bucket        = lower("${local.identifier}-lambdas-${var.suffix}")
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "lambdas_source_code" {
  bucket = aws_s3_bucket.lambdas_source_code.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "lambdas_source_code" {
  bucket = aws_s3_bucket.lambdas_source_code.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.lambdas_source_code
  ]
}

resource "aws_s3_bucket_public_access_block" "lambdas_source_code" {
  bucket = aws_s3_bucket.lambdas_source_code.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "lambdas_source_code" {
  bucket = aws_s3_bucket.lambdas_source_code.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lambdas_source_code" {
  bucket = aws_s3_bucket.lambdas_source_code.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
