# 1. Custom VPC ID
output "vpc_id" {
  description = "The ID of the Custom VPC"
  value       = aws_vpc.vpc-001.id
}

# 2. Public Subnet IDs
output "public_subnet_ids" {
  description = "IDs of the public subnets (Multi-AZ)"
  value       = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

# 3. Private Subnet IDs
output "private_subnet_ids" {
  description = "IDs of the private subnets (Multi-AZ)"
  value       = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

# 4. Elastic IP of the NAT Gateway
output "nat_gateway_ip" {
  description = "The Elastic IP address assigned to the NAT Gateway"
  value       = aws_eip.nat-eip-001.public_ip
}

# 5. Internet Gateway ID
output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.igw-001.id
}
