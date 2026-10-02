# ====================================================
# 1. Dynamically find the latest Ubuntu 24.04 AMI
# ====================================================
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's official AWS Account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ====================================================
# 2. Launch Template (App Tier Configuration)
# ====================================================
resource "aws_launch_template" "main" {
  name_prefix   = "${var.project_name}-template-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  # Attach the private EC2 Security Group
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  # User Data: Installs Nginx + MySQL client, tests DB connection, and serves dashboard
  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y nginx default-mysql-client

              systemctl start nginx
              systemctl enable nginx

              # Grab Instance Metadata using IMDSv2 (with security token)
              TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
              PRIVATE_IP=$(hostname -I | awk '{print $1}')
              AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)

              # Database Connection Details injected from Terraform
              DB_HOST="${aws_db_instance.main.address}"
              DB_USER="${var.db_username}"
              DB_PASS="${random_password.db_password.result}"
              DB_NAME="${var.db_name}"

              # Test connection to RDS MySQL
              if mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "USE $DB_NAME; SELECT 1;" > /dev/null 2>&1; then
                DB_STATUS="✅ CONNECTED TO RDS MYSQL"
                DB_COLOR="#22c55e"
              else
                DB_STATUS="⚠️ CONNECTING TO RDS..."
                DB_COLOR="#f59e0b"
              fi

              # Create a modern 3-Tier Dashboard
              cat <<HTML > /var/www/html/index.html
              <!DOCTYPE html>
              <html lang="en">
              <head>
                <meta charset="UTF-8">
                <title>Enterprise 3-Tier Application</title>
                <style>
                  body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background: #0f172a; color: #f8fafc; text-align: center; padding-top: 50px; }
                  .container { max-width: 650px; margin: 0 auto; background: #1e293b; border: 1px solid #334155; border-radius: 16px; padding: 35px; box-shadow: 0 10px 25px rgba(0,0,0,0.5); }
                  h1 { color: #38bdf8; margin-bottom: 20px; font-size: 24px; }
                  .tier-box { background: #0f172a; border: 1px solid #334155; border-radius: 10px; padding: 15px; margin: 12px 0; text-align: left; }
                  .tier-title { font-weight: bold; color: #94a3b8; font-size: 13px; text-transform: uppercase; letter-spacing: 1px; }
                  .status-pill { display: inline-block; padding: 4px 12px; border-radius: 99px; font-weight: bold; font-size: 14px; color: white; }
                  .db-status { background: $DB_COLOR; }
                  .az-pill { background: #6366f1; }
                  code { background: #334155; padding: 2px 6px; border-radius: 4px; font-family: monospace; color: #38bdf8; }
                </style>
              </head>
              <body>
                <div class="container">
                  <h1>🏛️ Enterprise 3-Tier Web Architecture</h1>
                  
                  <div class="tier-box">
                    <div class="tier-title">Tier 1: Web / Presentation</div>
                    <p>Load Balancer: <strong>Application Load Balancer (Port 80)</strong></p>
                  </div>

                  <div class="tier-box">
                    <div class="tier-title">Tier 2: Application / Logic</div>
                    <p>Serving from Private IP: <strong>$PRIVATE_IP</strong></p>
                    <p>Availability Zone: <span class="status-pill az-pill">$AZ</span></p>
                  </div>

                  <div class="tier-box">
                    <div class="tier-title">Tier 3: Database / Data Tier</div>
                    <p>Status: <span class="status-pill db-status">$DB_STATUS</span></p>
                    <p>Database Endpoint: <code>$DB_HOST</code></p>
                    <p>Database Name: <code>$DB_NAME</code></p>
                  </div>
                </div>
              </body>
              </html>
              HTML
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-ec2-instance"
      Tier = "Tier-2-App"
    }
  }
}

# ====================================================
# 3. Auto Scaling Group (Fleet Manager)
# ====================================================
resource "aws_autoscaling_group" "main" {
  name_prefix         = "${var.project_name}-asg-"
  vpc_zone_identifier = data.aws_subnets.default.ids

  # Fleet Dimensions
  min_size         = var.asg_min_size         # 2
  max_size         = var.asg_max_size         # 4
  desired_capacity = var.asg_desired_capacity # 2

  # Connect to the ALB Target Group
  target_group_arns = [aws_lb_target_group.main.arn]

  # Smart Health Check
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  # Ensure the database is 100% ready before launching EC2 instances
  depends_on = [aws_db_instance.main]
}
