output "alb_url" {
  description = "Public URL to access the containerized microservice via Load Balancer"
  value       = "http://${aws_lb.main.dns_name}"
}

output "ecs_cluster_name" {
  description = "The name of the ECS Cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "The name of the ECS Service"
  value       = aws_ecs_service.main.name
}

output "cloudwatch_log_group" {
  description = "CloudWatch log group where container stdout/stderr logs stream"
  value       = aws_cloudwatch_log_group.ecs_logs.name
}
