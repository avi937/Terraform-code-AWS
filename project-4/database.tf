# ====================================================
# 1. Database Subnet Group (Multi-AZ Network Foundation)
# ====================================================
resource "aws_db_subnet_group" "main" {
  name        = "${var.project_name}-db-subnet-group"
  description = "Subnet group for ${var.project_name} database"
  subnet_ids  = data.aws_subnets.default.ids

  tags = {
    Name = "${var.project_name}-db-subnet-group"
    Tier = "Tier-3-Database"
  }
}

# ====================================================
# 2. Amazon RDS MySQL Database Instance
# ====================================================
resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-db"

  # Engine configuration
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = var.db_instance_class # db.t3.micro (Free Tier)

  # Storage configuration
  allocated_storage     = var.db_allocated_storage # 20 GB gp3
  max_allocated_storage = 50                       # Storage Auto-Scaling: scales up to 50 GB automatically if disk fills up!
  storage_type          = "gp3"

  # Database Credentials (Injected dynamically from secrets.tf!)
  db_name  = var.db_name
  username = var.db_username
  password = random_password.db_password.result

  # Network & Security
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  publicly_accessible    = false # NO public IP! Completely invisible to the internet.

  # Backup & Maintenance Settings for Dev/Testing
  skip_final_snapshot = true  # Required so "terraform destroy" can delete cleanly without waiting for a final snapshot
  deletion_protection = false # Allows Terraform to manage the lifecycle cleanly

  tags = {
    Name = "${var.project_name}-mysql-db"
    Tier = "Tier-3-Database"
  }
}
