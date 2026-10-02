# ====================================================
# 1. Fetch the Default VPC in Mumbai
# ====================================================
data "aws_vpc" "default" {
  default = true
}

# ====================================================
# 2. Fetch all Subnets in that Default VPC
# (Covers Mumbai Availability Zones: ap-south-1a, 1b, 1c)
# ====================================================
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
