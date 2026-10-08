terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "uptime-platform"
      Environment = "dev"
      Owner       = "platform-team"
      ManagedBy   = "terraform"
      Repository  = "terraform-aws-platform-live"
    }
  }
}