# ====================================================
# 1. Generate a Cryptographically Secure Random Password
# ====================================================
resource "random_password" "db_password" {
  length           = 16
  special          = true
  # Exclude tricky characters like / @ " or space that can break database URLs
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# ====================================================
# 2. Create the Secret "Vault" in AWS Secrets Manager
# ====================================================
resource "aws_secretsmanager_secret" "db_secret" {
  name_prefix             = "${var.project_name}-db-credentials-"
  description             = "Master database credentials for ${var.project_name}"
  recovery_window_in_days = 0 # Allows immediate clean deletion when running terraform destroy
}

# ====================================================
# 3. Store the Username and Password inside the Vault as JSON
# ====================================================
resource "aws_secretsmanager_secret_version" "db_secret_val" {
  secret_id = aws_secretsmanager_secret.db_secret.id

  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
  })
}
