terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  # Isolated Remote State for Project 4 in your S3 bucket
  backend "s3" {
    bucket         = "terraform-file-0025-12"
    key            = "project-4/terraform.tfstate"
    region         = "ap-south-1"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "Project-4-3Tier-App"
      Environment = "dev"
      ManagedBy   = "Terraform"
    }
  }
}
