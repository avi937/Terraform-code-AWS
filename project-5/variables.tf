variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name prefix for tagging and resource naming"
  type        = string
  default     = "static-site-cdn"
}
