#!/bin/bash

apt-get update -y
apt-get upgrade -y

# Install docker
apt-get install -y ca-certificates curl gnupg lsb-release
mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl start docker
systemctl enable docker

usermod -aG docker ubuntu
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Create directory for WireGuard
mkdir -p /home/ubuntu/wireguard
cd /home/ubuntu/wireguard

# Create SSL certificates directory
mkdir -p ssl

# Generate self-signed SSL certificate (valid for 365 days)
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout ssl/privkey.pem \
    -out ssl/fullchain.pem \
    -subj "/C=US/ST=State/L=City/O=Organization/OU=OrgUnit/CN=wireguard"

# Create Nginx configuration
cat > nginx.conf << 'EOF'
server {
    listen 443 ssl http2;
    server_name _;

    ssl_certificate /etc/nginx/ssl/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/privkey.pem;
    
    # Modern SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options DENY always;
    add_header X-Content-Type-Options nosniff always;

    location / {
        proxy_pass http://wg-easy:51821;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name _;
    return 301 https://$server_name$request_uri;
}
EOF

# Create docker-compose.yml with SSL proxy
cat > docker-compose.yml << 'EOF'
volumes:
  etc_wireguard:

services:
  wg-easy:
    environment:
      - WG_DEFAULT_DNS=1.1.1.1
      - WG_ALLOWED_IPS=0.0.0.0/0
      - WG_PERSISTENT_KEEPALIVE=25
      - WG_DEFAULT_ADDRESS=10.8.0.x
      - INSECURE=true
    image: ghcr.io/wg-easy/wg-easy:15
    container_name: wg-easy
    networks:
      - wg
    volumes:
      - etc_wireguard:/etc/wireguard
      - /lib/modules:/lib/modules:ro
    ports:
      - "51820:51820/udp"  # WireGuard VPN port (still exposed directly)
    expose:
      - "51821"  # Web UI (only accessible via nginx proxy)
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    sysctls:
      - net.ipv4.ip_forward=1
      - net.ipv4.conf.all.src_valid_mark=1
      - net.ipv6.conf.all.disable_ipv6=0
      - net.ipv6.conf.all.forwarding=1
      - net.ipv6.conf.default.forwarding=1

  nginx:
    image: nginx:alpine
    container_name: wireguard-nginx
    networks:
      - wg
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    ports:
      - "80:80"    # HTTP (redirects to HTTPS)
      - "443:443"  # HTTPS
    restart: unless-stopped
    depends_on:
      - wg-easy

networks:
  wg:
    driver: bridge
    enable_ipv6: true
    ipam:
      driver: default
      config:
        - subnet: 10.42.42.0/24
        - subnet: fdcc:ad94:bacf:61a3::/64
EOF

chown -R ubuntu:ubuntu /home/ubuntu/wireguard

# Enable IP forwarding permanently
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
echo 'net.ipv6.conf.all.forwarding=1' >> /etc/sysctl.conf
sysctl -p

cd /home/ubuntu/wireguard
docker-compose up -d
