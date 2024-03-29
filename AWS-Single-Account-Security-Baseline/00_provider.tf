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
      version = "~> 4.59.0"
      }
  }

  required_version = ">= 0.14.0"
}

provider "aws" {
  region = var.region
}