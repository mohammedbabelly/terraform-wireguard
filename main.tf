terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# AMI mapping for Ubuntu 24.04 LTS across regions
locals {
  region_ami_map = {
    "us-east-1"      = "ami-0e2c8caa4b6378d8c"
    "us-east-2"      = "ami-0ea3c35c5c3284d82"
    "us-west-1"      = "ami-0472eef47f816e45d"
    "us-west-2"      = "ami-0aff18ec83b712f05"
    "eu-west-1"      = "ami-0c76bd4bd302b30ec"
    "eu-west-2"      = "ami-0fb391cce7a602d1f"
    "eu-west-3"      = "ami-05b5a865c3579bbc4"
    "eu-central-1"   = "ami-0e067cc8a2b58de59"
    "eu-north-1"     = "ami-042b4708b1d05f512"
    "ap-southeast-1" = "ami-047126e50991d067b"
    "ap-southeast-2" = "ami-0146fc9ad419e2cfd"
    "ap-northeast-1" = "ami-0f36dcfcc94112ea1"
    "ap-northeast-2" = "ami-062cf18d655c0b1e8"
    "ap-south-1"     = "ami-0dee22c13ea7a9a67"
    "sa-east-1"      = "ami-0c2b8ca1dad447f8a"
    "ca-central-1"   = "ami-0ea418336406c6c43"
  }
  
  # Select the AMI for the chosen region
  ami_id = local.region_ami_map[var.aws_region]
}

# Create Security Group for WireGuard
resource "aws_security_group" "wireguard_sg" {
  name_prefix = "wireguard-sg-"
  description = "Security group for WireGuard VPN server"

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }

  # WireGuard VPN port
  ingress {
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "WireGuard VPN"
  }

  # WireGuard Web UI
  ingress {
    from_port   = 51821
    to_port     = 51821
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "WireGuard Web UI"
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name = "WireGuard Security Group"
  }
}

# Create EC2 instance
resource "aws_instance" "wireguard_server" {
  ami                    = local.ami_id
  instance_type          = "t3.nano"
  key_name              = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.wireguard_sg.id]

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {}))

  # Add more storage if needed (optional)
  root_block_device {
    volume_type = "gp3"
    volume_size = 8
    encrypted   = true
  }

  tags = {
    Name = var.instance_name
  }

  # Ensure the instance is created after the security group
  depends_on = [aws_security_group.wireguard_sg]
}

# Create Elastic IP for consistent public IP
resource "aws_eip" "wireguard_eip" {
  instance = aws_instance.wireguard_server.id
  domain   = "vpc"

  tags = {
    Name = "WireGuard Server EIP"
  }

  depends_on = [aws_instance.wireguard_server]
}