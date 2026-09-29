# 1. Automatically find the latest ubuntu ami
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

# 2. Launch the ec2 instance
resource "aws_instance" "my-ec2-001" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  # Attach the key pair we generated in main.tf
  key_name = aws_key_pair.key_pair.key_name

  # Attach the security group
  vpc_security_group_ids = [aws_security_group.ec2_terraform-001.id]

  # Attach the startup script
  user_data                   = file("userdata.sh")
  user_data_replace_on_change = true

  tags = {
    Name = var.instance_name
  }
}
