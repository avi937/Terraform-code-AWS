# ====================================================
# 1. Public Route Table & Subnet Associations
# ====================================================

# The Public Rulesheet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc-001.id

  # Direction: Any traffic heading to the internet goes to the IGW!
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-001.id
  }

  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

# Link Public Subnet 1 to the Public Route Table
resource "aws_route_table_association" "link_public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

# Link Public Subnet 2 to the Public Route Table
resource "aws_route_table_association" "link_public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# ====================================================
# 2. Private Route Table & Subnet Associations
# ====================================================

# The Private Rulesheet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc-001.id

  # Direction: Any outbound traffic heading to the internet goes to the NAT Gateway!
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw-001.id
  }

  tags = {
    Name = "${var.vpc_name}-private-rt"
  }
}

# Link Private Subnet 1 to the Private Route Table
resource "aws_route_table_association" "link_private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

# Link Private Subnet 2 to the Private Route Table
resource "aws_route_table_association" "link_private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}
