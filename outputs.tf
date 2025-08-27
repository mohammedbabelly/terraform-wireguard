output "wireguard_public_ip" {
  description = "Public IP address of the WireGuard server"
  value       = aws_eip.wireguard_eip.public_ip
}

output "wireguard_public_dns" {
  description = "Public DNS name of the WireGuard server"
  value       = aws_instance.wireguard_server.public_dns
}

# Updated for HTTPS access
output "wireguard_web_ui_https_url" {
  description = "HTTPS URL to access the WireGuard web interface (recommended)"
  value       = "https://${aws_eip.wireguard_eip.public_ip}"
}

# HTTP URL (redirects to HTTPS)
output "wireguard_web_ui_http_url" {
  description = "HTTP URL (automatically redirects to HTTPS)"
  value       = "http://${aws_eip.wireguard_eip.public_ip}"
}

# VPN server endpoint
output "wireguard_vpn_endpoint" {
  description = "WireGuard VPN server endpoint (for client configuration)"
  value       = "${aws_eip.wireguard_eip.public_ip}:51820"
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

# SSL Certificate info
output "ssl_certificate_info" {
  description = "SSL certificate information"
  value       = "Self-signed certificate - click 'Advanced' → 'Proceed to site' in browser to accept"
}

# Quick setup instructions
output "setup_instructions" {
  description = "Quick setup instructions"
  value = <<EOT
🚀 WireGuard Server Ready!

1. Web UI (HTTPS): https://${aws_eip.wireguard_eip.public_ip}
   - Accept the self-signed certificate warning
   - Create your VPN clients

2. VPN Endpoint: ${aws_eip.wireguard_eip.public_ip}:51820
   - Use this in your WireGuard client apps

3. SSH Access: ssh -i ~/.ssh/${var.ssh_key_name}.pem ubuntu@${aws_eip.wireguard_eip.public_ip}

Note: Allow 2-3 minutes for the server to fully initialize after deployment.
EOT
}