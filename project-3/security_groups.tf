# ====================================================
# 1. ALB Security Group (Public-Facing)
# ====================================================
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Allow HTTP inbound traffic from the entire internet"
  vpc_id      = data.aws_vpc.default.id

  # Allow internet users to access the Load Balancer on Port 80
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow the Load Balancer to forward traffic to the EC2 instances
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

# ====================================================
# 2. EC2 Security Group (Private to the ALB)
# ====================================================
resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-ec2-sg"
  description = "Allow HTTP traffic ONLY from the Load Balancer"
  vpc_id      = data.aws_vpc.default.id

  # Notice this! Instead of cidr_blocks = ["0.0.0.0/0"],
  # we ONLY allow the ALB's Security Group!
  ingress {
    description     = "HTTP only from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id] # <-- THE VIP VELVET ROPE!
  }

    # Rule 2: SSH so you can log in and debug!
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow instances to download packages
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ec2-sg"
  }
}
