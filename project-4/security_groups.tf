# ====================================================
# Tier 1: Application Load Balancer Security Group
# (Public Facing - Talks to the entire internet)
# ====================================================
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Tier 1: Allow public HTTP traffic to ALB"
  vpc_id      = data.aws_vpc.default.id

  # Inbound: Allow anyone on the internet to visit on Port 80
  ingress {
    description = "Public HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound: Forward requests to EC2 instances
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
    Tier = "Tier-1-Web"
  }
}

# ====================================================
# Tier 2: EC2 App Server Security Group
# (Private - Talks ONLY to ALB and Database)
# ====================================================
resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-ec2-sg"
  description = "Tier 2: Allow HTTP traffic ONLY from the ALB"
  vpc_id      = data.aws_vpc.default.id

  # Inbound: Accept HTTP requests ONLY from the ALB Security Group!
  ingress {
    description     = "HTTP traffic strictly from ALB SG"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Inbound: SSH for debugging/administration
  ingress {
    description = "SSH from anywhere for admin debugging"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound: Needs to reach RDS (port 3306), internet (for packages), and Secrets Manager
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ec2-sg"
    Tier = "Tier-2-App"
  }
}

# ====================================================
# Tier 3: Database (RDS MySQL) Security Group
# (Deep Private - Talks ONLY to EC2 App Servers)
# ====================================================
resource "aws_security_group" "db_sg" {
  name        = "${var.project_name}-db-sg"
  description = "Tier 3: Allow MySQL traffic ONLY from EC2 App servers"
  vpc_id      = data.aws_vpc.default.id

  # Inbound: Accept MySQL traffic (Port 3306) strictly from the EC2 Security Group!
  ingress {
    description     = "MySQL port 3306 strictly from EC2 instances"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  # Outbound: Database only responds to EC2 queries
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-db-sg"
    Tier = "Tier-3-Database"
  }
}
