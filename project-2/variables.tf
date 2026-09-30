variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_name" {
  description = "vpc name prefix for tags"
  type        = string
  default     = "terraform-001-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the whole VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (Multi-AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (Multi-AZ)"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "availability_zones" {
  description = "Availability Zones in Mumbai"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}
