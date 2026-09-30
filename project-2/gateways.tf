# 1. Internet Gateway (Front door for public subnets)
resource "aws_internet_gateway" "igw-001" {
  vpc_id = aws_vpc.vpc-001.id

  tags = {
    Name = "${var.vpc_name}-igw-001"
  }
}

# 2. Elastic IP (Static Public IP for the NAT Gateway)
resource "aws_eip" "nat-eip-001" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw-001]

  tags = {
    Name = "${var.vpc_name}-nat-eip-001"
  }
}

# 3. NAT Gateway (Sits in Public Subnet 1)
resource "aws_nat_gateway" "nat-gw-001" {
  allocation_id = aws_eip.nat-eip-001.id
  subnet_id     = aws_subnet.public_1.id

  tags = {
    Name = "${var.vpc_name}-nat-gw-001"
  }

  depends_on = [aws_internet_gateway.igw-001]
}
