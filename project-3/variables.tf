variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Prefix for naming resources"
  type        = string
  default     = "terraform-001"
}

variable "instance_type" {
  description = "EC2 instance size"
  type        = string
  default     = "t3.micro"
}

# Auto Scaling Dimensions
variable "asg_min_size" {
  description = "Minimum number of EC2 instances running"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum number of EC2 instances that can scale up"
  type        = number
  default     = 4
}

variable "asg_desired_capacity" {
  description = "Standard number of instances running at all times"
  type        = number
  default     = 2
}
