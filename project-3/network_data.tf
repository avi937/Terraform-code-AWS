# 1. Find the default VPC in Mumbai
data "aws_vpc" "default" {
  default = true
}

# 2. Find all default subnets in that VPC (across Mumbai Zone A & Zone B)
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}



/*
What does data mean in Terraform?
-> resource means: "Hey AWS, CREATE something new."
-> data means: "Hey AWS, FIND something that already exists."
   This automatically finds your free Mumbai VPC and its multi-AZ 
   subnets without building a new network!*/