# ====================================================
# 1. The Application Load Balancer
# ====================================================
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false                         # False = Public internet-facing
  load_balancer_type = "application"                 # Layer 7 (HTTP/HTTPS) Load Balancer
  security_groups    = [aws_security_group.alb_sg.id] # Attach the ALB firewall
  subnets            = data.aws_subnets.default.ids  # Deploys across Mumbai Zone A, B, and C

  tags = {
    Name = "${var.project_name}-alb"
  }
}

# ====================================================
# 2. Target Group & Health Checks
# ====================================================
resource "aws_lb_target_group" "main" {
  name     = "${var.project_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  # Health Check: Pings every instance to make sure it's alive!
  health_check {
    path                = "/"     # Pings http://instance-ip/
    protocol            = "HTTP"
    matcher             = "200"   # Expects HTTP 200 OK
    interval            = 15      # Check every 15 seconds
    timeout             = 5       # Wait 5 seconds for a response
    healthy_threshold   = 2       # Mark 'Healthy' after 2 successful checks
    unhealthy_threshold = 2       # Mark 'Unhealthy' after 2 failed checks
  }

  tags = {
    Name = "${var.project_name}-tg"
  }
}

# ====================================================
# 3. The Listener (The Bridge)
# ====================================================
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn # Listens on our ALB
  port              = 80
  protocol          = "HTTP"

  # What to do when someone visits: Forward traffic to our Target Group!
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}
