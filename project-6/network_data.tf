# Fetch the default VPC in your region
data "aws_vpc" "default" {
  default = true
}

# Fetch all public subnets inside the default VPC across Availability Zones
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
