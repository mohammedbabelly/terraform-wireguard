output "wireguard_public_ip" {
  description = "Public IP address of the WireGuard server"
  value       = aws_eip.wireguard_eip.public_ip
}

output "wireguard_public_dns" {
  description = "Public DNS name of the WireGuard server"
  value       = aws_instance.wireguard_server.public_dns
}

output "wireguard_web_ui_url" {
  description = "URL to access the WireGuard web interface"
  value       = "http://${aws_eip.wireguard_eip.public_ip}:51821"
}

# Output SSH connection command
output "ssh_connection_command" {
  description = "SSH command to connect to the server"
  value       = "ssh -i ~/.ssh/${var.ssh_key_name}.pem ubuntu@${aws_eip.wireguard_eip.public_ip}"
}

output "deployed_region" {
  description = "AWS region where the server was deployed"
  value       = var.aws_region
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.wireguard_server.id
}