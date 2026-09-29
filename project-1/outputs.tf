output "server_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.my-ec2-001.public_ip
}

output "ssh_command" {
  description = "Command to SSH into the instance"
  value       = "ssh -i Terraform-Key.pem ubuntu@${aws_instance.my-ec2-001.public_ip}"
}
