output "alb_dns_name" {
  description = "The public URL of the Application Load Balancer"
  value       = "http://${aws_lb.main.dns_name}"
}
