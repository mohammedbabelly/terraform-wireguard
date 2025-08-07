variable "aws_access_key" {
  description = "AWS access key ID"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS secret access key"
  type        = string
  sensitive   = true
}

# AWS Region - Terraform will prompt for this with descriptive options
variable "aws_region" {
  description = <<EOF
AWS region to deploy the WireGuard server

Available regions:
  us-east-1      - US East (N. Virginia)
  us-east-2      - US East (Ohio)
  us-west-1      - US West (N. California)
  us-west-2      - US West (Oregon)
  eu-west-1      - Europe (Ireland)
  eu-west-2      - Europe (London)
  eu-west-3      - Europe (Paris)
  eu-central-1   - Europe (Frankfurt)
  eu-north-1     - Europe (Stockholm)
  ap-southeast-1 - Asia Pacific (Singapore)
  ap-southeast-2 - Asia Pacific (Sydney)
  ap-northeast-1 - Asia Pacific (Tokyo)
  ap-northeast-2 - Asia Pacific (Seoul)
  ap-south-1     - Asia Pacific (Mumbai)
  sa-east-1      - South America (São Paulo)
  ca-central-1   - Canada (Central)

Enter region code (e.g., eu-north-1)
EOF
  type = string
  
  validation {
    condition = contains([
      "us-east-1", "us-east-2", "us-west-1", "us-west-2",
      "eu-west-1", "eu-west-2", "eu-west-3", "eu-central-1", "eu-north-1",
      "ap-southeast-1", "ap-southeast-2", "ap-northeast-1", "ap-northeast-2",
      "ap-south-1", "sa-east-1", "ca-central-1"
    ], var.aws_region)
    error_message = "Please select a valid AWS region from the list above."
  }
}

# SSH Key Name - Terraform will prompt for this
variable "ssh_key_name" {
  description = <<EOF
Name of the SSH key pair to use for EC2 access
(Must exist in the selected AWS region)

To create a key pair:
1. Go to AWS Console → EC2 → Key Pairs
2. Click "Create key pair"
3. Enter a name (e.g., 'wireguard-key')
4. Choose RSA and .pem format
5. Download and save the .pem file
6. Set permissions: chmod 400 ~/Downloads/your-key.pem

Enter the key pair name
EOF
  type = string
}

# Instance Name - Terraform will prompt for this
variable "instance_name" {
  description = "Name tag for the EC2 instance (e.g., 'my-vpn-server')"
  type        = string
  
  validation {
    condition     = length(var.instance_name) > 0 && length(var.instance_name) <= 255
    error_message = "Instance name must be between 1 and 255 characters."
  }
}
