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
  me-south-1     - Middle East (Bahrin 🇧🇭)
  me-central-1   - Middle East (UAE 🇦🇪)
  us-east-1      - US East (N. Virginia 🇺🇸)
  us-east-2      - US East (Ohio 🇺🇸)
  us-west-1      - US West (N. California 🇺🇸)
  us-west-2      - US West (Oregon 🇺🇸)
  eu-west-1      - Europe (Ireland 🇮🇪)
  eu-west-2      - Europe (London 🇬🇧)
  eu-west-3      - Europe (Paris 🇫🇷)
  eu-central-1   - Europe (Frankfurt 🇩🇪)
  eu-north-1     - Europe (Stockholm 🇸🇪)
  eu-south-1     - Europe (Milan 🇮🇹)
  ap-southeast-1 - Asia Pacific (Singapore 🇸🇬)
  ap-northeast-1 - Asia Pacific (Tokyo 🇯🇵)
  ap-south-1     - Asia Pacific (Mumbai 🇮🇳)
  ca-central-1   - Canada (Central 🇨🇦)

Enter region code (e.g., eu-south-1)
EOF
  type = string
  
  validation {
    condition = contains([
      "me-south-1", "me-central-1",
      "us-east-1", "us-east-2", "us-west-1", "us-west-2",
      "eu-west-1", "eu-west-2", "eu-west-3", "eu-central-1", "eu-north-1", "eu-south-1",
      "ap-southeast-1", "ap-northeast-1",
      "ap-south-1", "ca-central-1"
    ], var.aws_region)
    error_message = "Please select a valid AWS region from the list above."
  }
}

# Instance Type - Performance vs Cost selection
variable "instance_type" {
  description = <<EOF
EC2 instance type - Choose based on your speed requirements

Performance comparison (Your connection: 750 Mbps):

BUDGET OPTIONS:
  t2.micro    - 1 vCPU, 1GB RAM  | VPN Speed: ~50-100 Mbps  | Cost: ~$8/month
  t2.small    - 1 vCPU, 2GB RAM  | VPN Speed: ~100-200 Mbps | Cost: ~$17/month

RECOMMENDED OPTIONS:
  t3.micro    - 2 vCPU, 1GB RAM  | VPN Speed: ~200-400 Mbps | Cost: ~$8/month
  t3.small    - 2 vCPU, 2GB RAM  | VPN Speed: ~400-600 Mbps | Cost: ~$17/month
  t3.medium   - 2 vCPU, 4GB RAM  | VPN Speed: ~600-800 Mbps | Cost: ~$33/month

HIGH PERFORMANCE:
  c5.large    - 2 vCPU, 4GB RAM  | VPN Speed: ~800+ Mbps    | Cost: ~$70/month
  c5.xlarge   - 4 vCPU, 8GB RAM  | VPN Speed: ~1000+ Mbps   | Cost: ~$140/month


Enter instance type (e.g., t3.small)
EOF
  type = string
  
  validation {
    condition = contains([
      "t2.micro", "t2.small", "t2.medium",
      "t3.micro", "t3.small", "t3.medium", "t3.large",
      "c5.large", "c5.xlarge", "c5.2xlarge"
    ], var.instance_type)
    error_message = "Please select a valid instance type from the options above."
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
