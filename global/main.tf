#Terraform state backend configuration for AWS S3 and DynamoDB


locals {
  bucket_name = "tfstate-${var.stage}-${data.aws_caller_identity.current.account_id}"
}


resource "aws_s3_bucket" "tfstate_bucket" {
  bucket = local.bucket_name

  tags = {
    Name        = local.bucket_name
    Environment = var.stage
    ManagedBy   = "terraform"
  }
}

# Block all public access (IMPORTANT)
resource "aws_s3_bucket_public_access_block" "tfstate_public_block" {
  bucket                  = aws_s3_bucket.tfstate_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning (required for Terraform)
resource "aws_s3_bucket_versioning" "tfstate_versioning" {
  bucket = aws_s3_bucket.tfstate_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate_encryption" {
  bucket = aws_s3_bucket.tfstate_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


# 5. DynamoDB Lock Table for Terraform
resource "aws_dynamodb_table" "tfstate_locks" {
  name         = "terraform-locks-${var.stage}"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "terraform-locks-${var.stage}"
    Environment = var.stage
    ManagedBy   = "terraform"
  }
}
