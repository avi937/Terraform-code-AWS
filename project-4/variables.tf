# ====================================================
# General Settings
# ====================================================
variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Prefix for resource naming"
  type        = string
  default     = "three-tier-app"
}

# ====================================================
# Tier 2: EC2 & Auto Scaling Variables
# ====================================================
variable "instance_type" {
  description = "EC2 instance size for web/app tier"
  type        = string
  default     = "t3.micro" # Remember Project 3: t3.micro is available in all Mumbai AZs!
}

variable "asg_min_size" {
  description = "Minimum EC2 instances running"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum EC2 instances that can scale up"
  type        = number
  default     = 4
}

variable "asg_desired_capacity" {
  description = "Normal running count of EC2 instances"
  type        = number
  default     = 2
}

# ====================================================
# Tier 3: Database (RDS MySQL) Variables
# ====================================================
variable "db_name" {
  description = "Name of the initial MySQL database"
  type        = string
  default     = "webappdb"
}

variable "db_username" {
  description = "Master administrator username for MySQL"
  type        = string
  default     = "dbadmin"
}

variable "db_instance_class" {
  description = "Database instance size"
  type        = string
  default     = "db.t3.micro" # Free Tier eligible!
}

variable "db_allocated_storage" {
  description = "Storage size in Gigabytes for the database"
  type        = number
  default     = 20 # 20 GB is within AWS Free Tier limits
}
