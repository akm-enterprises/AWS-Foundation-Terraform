//aws terraform request. give me breakdown of task to create cloudtrail with cmk, s3 and cloudwatch log group//


//1. AWS terraform request. Create "akm-enterprises-cloudtrail-eu" S3 bucket, https enforced, KMS CMK for the cloudtrail, s3 lifecycle policy of moving object to IA tier after 30 days, to galicer after 90 days and expiry object after 365 days.//


resource "aws_s3_bucket" "akm-enterprises-cloudtrail-eu" {
  bucket = "akm-enterprises-cloudtrail-eu"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
        kms_master_key_id = "arn:aws:kms:eu-west-1:&lt;account-id&gt;:key/&lt;key-id&gt;"
      }
    }
  }

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "move-to-ia-after-30-days"
    enabled = true

    prefix  = ""
    tags    = {}

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }

  lifecycle_rule {
    id      = "move-to-glacier-after-90-days"
    enabled = true

    prefix  = ""
    tags    = {}

    transition {
      days          = 90
      storage_class = "GLACIER"
    }
  }

  lifecycle_rule {
    id      = "expire-after-365-days"
    enabled = true

    prefix  = ""
    tags    = {}

    expiration {
      days = 365
    }
  }
}

resource "aws_s3_bucket_public_access_block" "akm-enterprises-cloudtrail-eu" {
  bucket = aws_s3_bucket.akm-enterprises-cloudtrail-eu.id
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "akm-enterprises-cloudtrail-eu" {
  bucket = aws_s3_bucket.akm-enterprises-cloudtrail-eu.id

  policy = &lt;&lt;POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::akm-enterprises-cloudtrail-eu/*",
      "Condition": {
        "StringNotEquals": {
          "aws:SecureTransport": "https"
        }
      }
    }
  ]
}
POLICY
}

//2. Create an IAM role with the necessary permissions to allow CloudTrail to write logs to the S3 bucket.

//3. Create a CloudTrail trail with the S3 bucket as the destination.

//4. Create a CloudWatch Logs log group to store CloudTrail logs.

//5. Create an IAM role with the necessary permissions to allow CloudTrail to write logs to the CloudWatch Logs log group.

//6. Create a KMS key to encrypt the CloudTrail logs.

//7. Update the CloudTrail trail to use the KMS key for encryption.

//8. Test the CloudTrail trail to ensure that logs are being written to the S3 bucket and CloudWatch Logs log group.