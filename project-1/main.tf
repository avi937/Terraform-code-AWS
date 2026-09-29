# 1. Generate an RSA Private Key in memory
resource "tls_private_key" "rsa_4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 2. Upload the Public Key to AWS EC2
resource "aws_key_pair" "key_pair" {
  key_name   = "Terraform-Key"
  public_key = tls_private_key.rsa_4096.public_key_openssh
}

# 3. Save the Private Key (.pem file) onto your laptop automatically
resource "local_file" "private_key" {
  content         = tls_private_key.rsa_4096.private_key_pem
  filename        = "Terraform-Key.pem"
  file_permission = "0400"
}
