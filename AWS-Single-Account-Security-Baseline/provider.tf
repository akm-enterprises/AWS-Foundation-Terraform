terraform {

  cloud {
    organization = "akm-enterprises"

    workspaces {
      name = "AWS-Foundation-Terraform"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.28.0"
      region = var.region
    }
  }

  required_version = ">= 0.14.0"
}