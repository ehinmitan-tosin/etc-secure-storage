terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Generate  a unique bucket suffix
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Create S3 bucket
resource "aws_s3_bucket" "secure_storage" {
  bucket = "etc-secure-storage-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "ETC Secure Storage"
    Environment = "Development"
    ManageBy    = "Terraform"
  }
}

# Enable versioning
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.secure_storage.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.secure_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.secure_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enforce bucket ownership
resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.secure_storage.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Display bucket name 
output "bucket_name" {
  value = aws_s3_bucket.secure_storage.bucket
}