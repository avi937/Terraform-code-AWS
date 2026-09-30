# Public Subnet in Zone A (10.0.1.0/24)
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.vpc-001.id         # <-- Links to your VPC!
  cidr_block              = var.public_subnet_cidrs[0] # Reads "10.0.1.0/24"
  availability_zone       = var.availability_zones[0]  # Reads "ap-south-1a"
  map_public_ip_on_launch = true                       # Any server here gets a Public IP automatically

  tags = {
    Name = "${var.vpc_name}-public-1a"
    Tier = "Public"
  }
}

# Public Subnet in Zone B (10.0.2.0/24)
resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.vpc-001.id
  cidr_block              = var.public_subnet_cidrs[1] # Reads "10.0.2.0/24"
  availability_zone       = var.availability_zones[1]  # Reads "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public-1b"
    Tier = "Public"
  }
}


# Private Subnet in Zone A (10.0.10.0/24)
resource "aws_subnet" "private_1" {
  vpc_id                  = aws_vpc.vpc-001.id
  cidr_block              = var.private_subnet_cidrs[0] # Reads "10.0.10.0/24"
  availability_zone       = var.availability_zones[0]   # Reads "ap-south-1a"
  map_public_ip_on_launch = false                       # Strictly NO public IPs!

  tags = {
    Name = "${var.vpc_name}-private-1a"
    Tier = "Private"
  }
}

# Private Subnet in Zone B (10.0.20.0/24)
resource "aws_subnet" "private_2" {
  vpc_id                  = aws_vpc.vpc-001.id
  cidr_block              = var.private_subnet_cidrs[1] # Reads "10.0.20.0/24"
  availability_zone       = var.availability_zones[1]   # Reads "ap-south-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.vpc_name}-private-1b"
    Tier = "Private"
  }
}
