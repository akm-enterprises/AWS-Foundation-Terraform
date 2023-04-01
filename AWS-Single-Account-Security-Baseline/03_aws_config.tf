resource "aws_s3_bucket" "akm_enterprises_configlog_eu" {
  bucket = "akm-enterprises-configlog-eu"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  # Block public access settings
  public_access_block_configuration {
    block_public_acls   = true
    block_public_policy = true
    ignore_public_acls  = true
    restrict_public_buckets = true
  }
}

data "aws_iam_policy_document" "akm_enterprises_configlog_eu_bucket_policy" {
  statement {
    actions   = ["s3:GetBucketAcl", "s3:PutObject"]
    resources = [
      aws_s3_bucket.akm_enterprises_configlog_eu.arn,
      "${aws_s3_bucket.akm_enterprises_configlog_eu.arn}/*"
    ]
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
  }
}

resource "aws_s3_bucket_policy" "akm_enterprises_configlog_eu_bucket_policy" {
  bucket = aws_s3_bucket.akm_enterprises_configlog_eu.id
  policy = data.aws_iam_policy_document.akm_enterprises_configlog_eu_bucket_policy.json
}

resource "aws_config_configuration_recorder" "config_recorder" {
  name     = "default"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "config_channel" {
  name           = "default"
  s3_bucket_name = aws_s3_bucket.akm_enterprises_configlog_eu.bucket
  depends_on     = [aws_config_configuration_recorder.config_recorder]
}

resource "aws_iam_role" "config_role" {
  name = "aws-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "config_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
  role       = aws_iam_role.config_role.name
}

resource "aws_config_configuration_recorder_status" "config_recorder_status" {
  name       = aws_config_configuration_recorder.config_recorder.name
  is_enabled = true
}
