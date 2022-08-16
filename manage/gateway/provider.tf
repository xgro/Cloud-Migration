# Required providers configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.6.0"
    }
  }

  backend "s3" {
    key            = "manage/gateway/terraform.tfstate"
  }

  required_version = ">= 1.0.11"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}