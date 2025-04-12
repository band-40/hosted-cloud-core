#!/bin/bash

# Exit on error
set -e

echo "Starting Open5GS installation at $(date)"
REPO_DIR="/tmp/hosted-cloud-core"

# Update repositories and packages
apt-get update
apt-get upgrade -y

# Install required packages
apt-get install -y nginx wget

# Setup welcome script
# cp ${REPO_DIR}/welcome.sh /home/epcuser/welcome.sh
# chmod 755 /home/epcuser/welcome.sh

# Setup web content
mkdir -p /var/www/html
cp ${REPO_DIR}/index.html /var/www/html/index.html
chmod 644 /var/www/html/index.html

# Setup nginx configuration
cp ${REPO_DIR}/nginx.conf /etc/nginx/sites-available/default
chmod 644 /etc/nginx/sites-available/default

# Install MongoDB for the WebUI
echo "Installing MongoDB for WebUI..."
# Import the public key used by the package management system
apt-get install -y gnupg
curl -fsSL https://pgp.mongodb.com/server-8.0.asc | gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor

# Create the list file for MongoDB
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/8.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-8.0.list

# Install MongoDB packages
apt-get update
apt-get install -y mongodb-org

# Start and enable MongoDB
systemctl start mongod
systemctl enable mongod

# Install dependencies
echo "Installing dependencies..."
apt-get install -y software-properties-common
add-apt-repository -y ppa:open5gs/latest
apt-get update

# Install Open5GS core packages
echo "Installing Open5GS core packages..."
apt-get install -y open5gs

# Install Node.js for WebUI
echo "Installing Node.js for WebUI..."
apt-get install -y curl
curl -sL https://deb.nodesource.com/setup_16.x | bash -
apt-get install -y nodejs

# Install WebUI using the official method
echo "Installing Open5GS WebUI..."
curl -fsSL https://open5gs.org/open5gs/assets/webui/install | bash -

# Modify the WebUI service to listen on all interfaces
echo "Configuring WebUI to listen on all interfaces (0.0.0.0)..."
sed -i '/^\[Service\]/a Environment=HOSTNAME=0.0.0.0' /lib/systemd/system/open5gs-webui.service

# Reload systemd to recognize changes and restart WebUI
systemctl daemon-reload
systemctl restart open5gs-webui

# Install StrongSwan
echo "Installing StrongSwan..."
apt-get install -y strongswan strongswan-pki charon-systemd

# Configure StrongSwan
echo "Configuring StrongSwan..."
# Get server's own IP address
SERVER_IP=$(hostname -I | awk '{print $1}')

# Create secrets file
cat > /etc/ipsec.secrets << EOF
# /etc/ipsec.secrets
# This file contains the PSK for the enb.
%any : PSK "amateuramateuramateur"
EOF
chmod 600 /etc/ipsec.secrets

# Create ipsec configuration
cat > /etc/ipsec.conf << EOF
# ipsec.conf

config setup
    uniqueids=never
    strictcrlpolicy=no

conn %default
    keyexchange=ikev2
    keyingtries=1

conn roadwarrior
    auto=add
    left=0.0.0.0
    leftid=am1
    leftsubnet=${SERVER_IP}/32
    right=%any
    rightid=%any
    rightsourceip=10.99.0.0/24
    type=tunnel
    leftauth=psk
    rightauth=psk
EOF

# Restart StrongSwan
systemctl restart strongswan
systemctl enable strongswan

# Configure UFW
echo "Configuring UFW..."
apt-get install -y ufw
ufw allow 80/tcp
ufw allow 8888/tcp
ufw allow 9999/tcp
ufw allow 443/tcp
ufw allow 500/udp
ufw allow 4500/udp
ufw --force enable

# Enable Open5GS services
for SERVICE in nrf amf smf upf ausf udm pcf nssf bsf udr; do
    systemctl enable open5gs-${SERVICE}d
    systemctl restart open5gs-${SERVICE}d
done

# Start and enable nginx
systemctl start nginx
systemctl enable nginx

# Run welcome script
# /home/epcuser/welcome.sh > /home/epcuser/init_complete.log

echo "Open5GS installation completed at $(date)"
echo "WebUI is available at http://$(hostname -I | awk '{print $1}')"
echo "Default WebUI credentials: admin / 1423" 