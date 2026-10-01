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
# 2. Launch Template (The Recipe for EC2 Instances)
# ====================================================
resource "aws_launch_template" "main" {
  name_prefix   = "${var.project_name}-template-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  # Attach the private EC2 Security Group!
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  # Startup script: installs Nginx and prints the server's Private IP & AZ
  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y nginx
              systemctl start nginx
              systemctl enable nginx

              # Grab this specific instance's Private IP & Availability Zone
              PRIVATE_IP=$(hostname -I | awk '{print $1}')
              AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)

              # Write a styled HTML page
              cat <<HTML > /var/www/html/index.html
              <!DOCTYPE html>
              <html>
              <head>
                <title>High Availability Web Server</title>
                <style>
                  body { font-family: -apple-system, sans-serif; text-align: center; margin-top: 60px; background: #0f172a; color: #f8fafc; }
                  .box { background: #1e293b; display: inline-block; padding: 40px; border-radius: 16px; border: 1px solid #334155; }
                  h1 { color: #38bdf8; }
                  .pill { background: #22c55e; color: white; padding: 4px 12px; border-radius: 99px; font-weight: bold; }
                </style>
              </head>
              <body>
                <div class="box">
                  <h1>🚀 High Availability Auto Scaling Fleet</h1>
                  <p>Serving from Private IP: <strong>$PRIVATE_IP</strong></p>
                  <p>Availability Zone: <span class="pill">$AZ</span></p>
                  <p>Managed by: <strong>AWS Auto Scaling & ALB</strong></p>
                </div>
              </body>
              </html>
              HTML
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-asg-instance"
    }
  }
}

# ====================================================
# 3. Auto Scaling Group (The Manager)
# ====================================================
resource "aws_autoscaling_group" "main" {
  name_prefix         = "${var.project_name}-asg-"
  vpc_zone_identifier = data.aws_subnets.default.ids # Launches across Mumbai Zone A, B, C

  # The Golden Triangle:
  min_size         = var.asg_min_size         # 2
  max_size         = var.asg_max_size         # 4
  desired_capacity = var.asg_desired_capacity # 2

  # Connect to the Target Group so ALB receives the instances!
  target_group_arns = [aws_lb_target_group.main.arn]

  # Smart Health Check: If ALB says an instance is unhealthy, replace it!
  health_check_type         = "ELB"
  health_check_grace_period = 300 # Give Nginx 5 minutes to install before checking

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }
}

# ====================================================
# 4. Auto Scaling Policy: Traffic-based (Scale Up & Down)
# ====================================================
resource "aws_autoscaling_policy" "traffic_policy" {
  name                   = "${var.project_name}-traffic-policy"
  autoscaling_group_name = aws_autoscaling_group.main.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${aws_lb.main.arn_suffix}/${aws_lb_target_group.main.arn_suffix}"
    }

    target_value = 20.0 # Target: 20 requests per instance per minute
  }
}

