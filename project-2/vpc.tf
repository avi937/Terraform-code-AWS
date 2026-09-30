#main custom vpc
resource "aws_vpc" "vpc-001" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true
    
    tags = {
      Name = var.vpc_name
    }
  
}