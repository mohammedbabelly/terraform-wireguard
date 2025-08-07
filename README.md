# WireGuard VPN Server with Terraform

This Terraform configuration automatically deploys a WireGuard VPN server on AWS EC2 with a web-based management interface.

## Features

- 🚀 **One-command deployment** of WireGuard VPN server
- 🔧 **Web-based management** interface (wg-easy)
- 🛡️ **Secure by default** with proper security groups
- 💰 **Cost-optimized** using t3.nano instances
- 🌍 **Multi-region support** - deploy anywhere
- 📱 **20 peer configurations** ready out of the box
- 🔒 **Elastic IP** for consistent connection

## Prerequisites

1. **AWS CLI configured** with appropriate permissions
2. **Terraform installed** (>= 1.0)
3. **SSH key pair** created in your target AWS region (see setup below)

### Install Terraform (if not installed)

**macOS:**
```bash
brew install terraform
```

**Ubuntu/Debian:**
```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

**Windows:**
Download from [terraform.io](https://www.terraform.io/downloads)

### Set Up SSH Key Pairs

**You need to create SSH key pairs manually in each region where you plan to deploy.**

#### Option 1: AWS Console (Easiest)

1. **Go to AWS Console** → **EC2** → **Key Pairs**
2. **Select your target region** (top-right corner)
3. Click **"Create key pair"**
4. **Name**: `wireguard-key` (or any name you prefer)
5. **Key pair type**: RSA
6. **Private key file format**: .pem
7. Click **"Create key pair"**
8. **Download and save** the .pem file securely
9. **Set permissions**: `chmod 400 ~/path/to/your-key.pem`

**Repeat for each region** you plan to use (same name, different regions).

#### Option 2: Import Existing Key (Advanced)

If you have an existing SSH key pair:

```bash
# Import your public key to multiple regions
aws ec2 import-key-pair --key-name "wireguard-key" --public-key-material fileb://~/.ssh/id_rsa.pub --region us-west-2
aws ec2 import-key-pair --key-name "wireguard-key" --public-key-material fileb://~/.ssh/id_rsa.pub --region eu-west-1
# Add more regions as needed
```

#### Option 3: Use Your Existing Keys

If you already have key pairs in some regions, just note their names. Terraform will prompt you for the key name during deployment.

## Quick Start

### 1. Clone/Download the Configuration

Create a new directory and save all the Terraform files:

```bash
mkdir wireguard-terraform
cd wireguard-terraform
# Save all .tf files and user_data.sh in this directory
```

### 2. Configure Your Settings

Copy the example configuration:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
aws_region = "eu-north-1"        # Your preferred region
ssh_key_name = "wireguard-key"   # Your SSH key name in AWS
instance_name = "My VPN Server"  # Name for your EC2 instance
wireguard_peers = 20             # Number of peer configs
```

**Important**: Make sure the `ssh_key_name` exists in your selected `aws_region`!

### 3. Deploy

```bash
# Initialize Terraform
terraform init

# Review the deployment plan
terraform plan

# Deploy the infrastructure
terraform apply
```

Type `yes` when prompted to confirm the deployment.

### 4. Access Your VPN

After deployment (takes ~3-5 minutes), Terraform will output:

```
wireguard_web_ui_url = "http://1.2.3.4:51821"
ssh_connection_command = "ssh -i ~/.ssh/my-key-pair.pem ubuntu@1.2.3.4"
```

Visit the web UI URL to manage your WireGuard VPN!

## WireGuard Client Setup

Once your VPN server is running, you can connect from any device using WireGuard clients. Here's how to set up each platform:

### 📱 **Mobile Devices**

#### **Android**
1. **Install WireGuard app** from [Google Play Store](https://play.google.com/store/apps/details?id=com.wireguard.android)
2. **Open the app** and tap the **"+"** button
3. **Scan QR Code**: 
   - Go to your web UI: `http://YOUR_IP:51821`
   - Find your device in the peer list
   - Tap the QR code icon
   - Scan with your phone
4. **Give it a name** (e.g., "My Phone") and tap **"Create Tunnel"**
5. **Connect** by toggling the switch

#### **iPhone/iPad (iOS)**
1. **Install WireGuard app** from [App Store](https://apps.apple.com/us/app/wireguard/id1441195209)
2. **Open the app** and tap **"Add a tunnel"**
3. **Scan QR Code**:
   - Go to your web UI: `http://YOUR_IP:51821`
   - Find your device in the peer list  
   - Tap the QR code icon
   - Scan with your iPhone
4. **Give it a name** and tap **"Save"**
5. **Connect** by toggling the switch

### 💻 **Desktop/Laptop**

#### **Windows**
1. **Download WireGuard** from [wireguard.com/install](https://www.wireguard.com/install/)
2. **Install and run** WireGuard
3. **Get config file**:
   - Go to your web UI: `http://YOUR_IP:51821`
   - Find your device in the peer list
   - Click the download icon to get `.conf` file
4. **Import config**: Click **"Add Tunnel"** → **"Import tunnel(s) from file"**
5. **Select your downloaded** `.conf` file
6. **Connect** by clicking **"Activate"**

#### **macOS**
1. **Install WireGuard** from [Mac App Store](https://apps.apple.com/us/app/wireguard/id1451685025) or download from [wireguard.com](https://www.wireguard.com/install/)
2. **Open WireGuard** application
3. **Get config file** from your web UI (same as Windows above)
4. **Import**: Click **"+"** → **"Import tunnel(s) from file"**
5. **Select your** `.conf` file and click **"Import"**
6. **Connect** by toggling the switch

## Managing Your VPN

### Access the Web Interface
- **URL**: `http://YOUR_IP:51821`
- **Default**: No password required (change this in production!)

### SSH to the Server
```bash
ssh -i ~/.ssh/your-key.pem ubuntu@YOUR_IP
```

### View Logs
```bash
# On the server
cd wireguard
docker-compose logs wg-easy
```

## Customization

### Change Instance Type
Edit `main.tf` and modify the `instance_type`:
```hcl
resource "aws_instance" "wireguard_server" {
  instance_type = "t3.small"  # Changed from t3.nano
  # ...
}
```

### Add More Security
Edit the security group in `main.tf` to restrict access:
```hcl
# Restrict SSH to your IP only
ingress {
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["YOUR_IP/32"]  # Replace YOUR_IP
  description = "SSH from my IP only"
}
```

### Enable HTTPS
To enable HTTPS, modify the docker-compose.yml template in `user_data.sh`:
```yaml
environment:
  - INSECURE=false  # Changed from true
```

## Cost Optimization

- **Instance**: t3.nano (~$3.80/month)
- **Storage**: 8GB gp3 (~$0.80/month)
- **Data Transfer**: $0.09/GB outbound
- **Elastic IP**: Free while attached

**Estimated monthly cost**: ~$5-15 depending on usage

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

Type `yes` to confirm. This will delete:
- EC2 instance
- Elastic IP
- Security Group
- All associated resources

## Troubleshooting

### Common Issues

**1. SSH Key Not Found**
```
Error: InvalidKeyPair.NotFound
```
**Solution**: 
- Ensure your SSH key exists in the selected region
- Go to AWS Console → EC2 → Key Pairs (in the correct region)
- Create the key pair if it doesn't exist
- Check the key name matches what you entered in terraform.tfvars

**2. Wrong Region Selected**
```
Error: collecting instance settings: couldn't find resource
```
**Solution**: Make sure your SSH key exists in the region you selected

**3. WireGuard Not Starting**
```bash
# SSH to the server and check
sudo tail -f /var/log/user-data.log
docker-compose logs wg-easy
```

**3. Can't Access Web UI**
- Check security group allows port 51821
- Verify instance is running: `terraform show`
- Check if Docker is running: `docker ps`

**4. Terraform Permission Issues**
Ensure your AWS user/role has these permissions:
- EC2: Create/modify instances, security groups, elastic IPs
- VPC: Describe VPCs, subnets

### Getting Help

1. Check the user-data log: `/var/log/user-data.log`
2. Verify Docker status: `systemctl status docker`
3. Check container logs: `docker-compose logs`

## Security Considerations

- Change the default web UI password
- Restrict security group access to known IPs
- Regularly update the Docker image
- Monitor access logs
- Consider enabling AWS CloudTrail

## Advanced Configuration

### Multiple Regions
Create separate terraform directories for each region, or use Terraform workspaces:

```bash
terraform workspace new us-west-2
terraform workspace new eu-west-1
```

### Automated Backups
Add this to your configuration for automated snapshots:

```hcl
# Add to main.tf
resource "aws_ebs_snapshot" "wireguard_backup" {
  volume_id   = aws_instance.wireguard_server.root_block_device[0].volume_id
  description = "WireGuard server backup"
  
  tags = {
    Name = "WireGuard Backup"
  }
}
```

Happy VPN-ing! 🔐