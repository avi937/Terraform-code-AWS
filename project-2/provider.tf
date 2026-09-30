terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Dedicated remote state for Project 2
  backend "s3" {
    bucket = "terraform-file-0025-12"
    key    = "project-2/terraform.tfstate"
    region = "ap-south-1"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "Project-2-VPC"
      Environment = "dev"
      ManagedBy   = "Terraform"
    }
  }
}
