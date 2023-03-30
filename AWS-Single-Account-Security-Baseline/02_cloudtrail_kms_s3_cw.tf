//aws terraform request. give me breakdown of task to create cloudtrail with cmk, s3 and cloudwatch log group//


//1. AWS terraform request. Create "akm-enterprises-cloudtrail-eu" S3 bucket, https enforced, KMS CMK key "aws_kms_key.akm-enterprises-cloudtrail.arn" s3 lifecycle policy of moving object to IA tier after 30 days, to galicer after 90 days and expiry object after 365 days.//

module "akm_enterprises_cloudtrail_eu" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "akm-enterprises-cloudtrail-eu"
  acl    = "private"

versioning = {
    enabled = true
  }


  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = aws_kms_key.akm-enterprises-cloudtrail.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
lifecycle_rule = {
    rule = {
      id      = "akm-enterprises-cloudtrail-eu-lifecycle"
      status = "Enabled"

      transition = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        },
      ]

      expiration = {
        days = 365
      }
    }
  }
  attach_policy = true
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "s3:*"
        Effect = "Deny"
        Resource = [
          module.akm_enterprises_cloudtrail_eu.s3_bucket_arn,
          "${module.akm_enterprises_cloudtrail_eu.s3_bucket_arn}/*"
        ]
        Principal = "*"
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}



resource "aws_iam_role" "akm-enterprises-cloudtrail-s3" {
  name = "akm-enterprises-cloudtrail-s3"

  assume_role_policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "akm-enterprises-cloudtrail-s3" {
  name = "akm-enterprises-cloudtrail-s3"

  policy = <<-EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::akm-enterprises-cloudtrail-eu/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "akm-enterprises-cloudtrail-s3" {
  role       = aws_iam_role.akm-enterprises-cloudtrail-s3.name
  policy_arn = aws_iam_policy.akm-enterprises-cloudtrail-s3.arn
}

//3. Create a CloudTrail trail with the S3 bucket as the destination.

resource "aws_cloudtrail" "akm_enterprises_cloudtrail" {
  name           = "akm-enterprises-cloudtrail"
  s3_bucket_name = module.akm_enterprises_cloudtrail_eu.s3_bucket_id

  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  cloud_watch_logs_group_arn = aws_cloudwatch_log_group.akm-enterprises-cloudtrail.arn
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail_role.arn

  kms_key_id = aws_kms_key.akm-enterprises-cloudtrail.arn
}


//4. terraform-aws-Create a CloudWatch Logs log group called "akm-enterprises-cloudtrail" with retention of 365 days to store CloudTrail logs.


resource "aws_cloudwatch_log_group" "akm-enterprises-cloudtrail" {
  name              = "akm-enterprises-cloudtrail"
  retention_in_days = 365
}

//5. terraform-aws Create an IAM role with the necessary permissions to allow CloudTrail to write logs to the CloudWatch Logs log group named "akm-enterprises-cloudtrail".


resource "aws_iam_role" "cloudtrail_role" {
  name = "akm-enterprises-cloudtrail-role"
  assume_role_policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "cloudtrail_policy" {
  name = "akm-enterprises-cloudtrail-policy"
  policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:*:*:log-group:akm-enterprises-cloudtrail:*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cloudtrail_policy_attachment" {
  role       = "${aws_iam_role.cloudtrail_role.name}"
  policy_arn = "${aws_iam_policy.cloudtrail_policy.arn}"
  }
  
//6. Terraform aws script request. Create a KMS key name "akm-enterprises-cloudtrail", enable key reotation for CloudTrail logs.


resource "aws_kms_key" "akm-enterprises-cloudtrail" {
  description             = "KMS key for CloudTrail logs"
  enable_key_rotation    = true
  deletion_window_in_days = 30
}


//7. Update the CloudTrail trail to use the KMS key for encryption.

//8. Test the CloudTrail trail to ensure that logs are being written to the S3 bucket and CloudWatch Logs log group.