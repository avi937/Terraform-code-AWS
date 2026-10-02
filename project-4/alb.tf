# ====================================================
# 1. Application Load Balancer (Public Facing)
# ====================================================
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false # Publicly accessible
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.aws_subnets.default.ids

  tags = {
    Name = "${var.project_name}-alb"
    Tier = "Tier-1-Web"
  }
}

# ====================================================
# 2. Target Group (Health Checks on App Port 80)
# ====================================================
resource "aws_lb_target_group" "main" {
  name     = "${var.project_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.project_name}-tg"
    Tier = "Tier-1-Web"
  }
}

# ====================================================
# 3. HTTP Listener (The Router: Port 80 -> Target Group)
# ====================================================
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}
