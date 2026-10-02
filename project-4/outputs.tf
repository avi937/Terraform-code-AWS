# ====================================================
# Tier 1: Public Web URL (Application Load Balancer)
# ====================================================
output "alb_dns_name" {
  description = "Public URL of the 3-Tier Web Application"
  value       = "http://${aws_lb.main.dns_name}"
}

# ====================================================
# Tier 3: Private Database Endpoint
# ====================================================
output "rds_endpoint" {
  description = "Private DNS endpoint of the RDS MySQL Database"
  value       = aws_db_instance.main.endpoint
}

# ====================================================
# DevSecOps: Secrets Manager Secret Name
# ====================================================
output "secrets_manager_secret_name" {
  description = "Name of the secret vault storing DB master credentials"
  value       = aws_secretsmanager_secret.db_secret.name
}
