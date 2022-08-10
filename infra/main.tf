# Required providers configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.9.0"
    }
  }

  required_version = ">= 1.0.11"
}

# AWS provider configuration
provider "aws" {
  profile = "aws"
  region  = "ap-northeast-2"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}






