module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "akm-enterprises-terraform-state-eu"
  acl    = "private"

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "s3:*"
        Effect = "Deny"
        Principal = "*"
        Resource = "arn:aws:s3:::akm-enterprises-terraform-state-eu/*"
        Condition = {
          Bool = {
            "aws:SecureTransport": "false"
          }
        }
      }
    ]
  })
}

output "s3_bucket_arn" {
  value = module.s3_bucket.s3_bucket_arn
}

