terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "uptime-platform"
      Environment = "shared"
      Owner       = "platform-team"
      ManagedBy   = "terraform"
      Repository  = "terraform-aws-platform-live"
    }
  }
}