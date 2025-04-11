#!/bin/bash

# Exit on error
set -e

echo "Starting Open5GS installation at $(date)"

# Update repositories and packages
apt-get update
apt-get upgrade -y

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

# Install Node.js for the WebUI
echo "Installing Node.js dependencies..."
apt-get install -y curl
curl -sL https://deb.nodesource.com/setup_16.x | bash -
apt-get install -y nodejs

# Clone and install the WebUI
echo "Setting up Open5GS WebUI..."
cd /opt
git clone https://github.com/open5gs/open5gs-webui
cd open5gs-webui
npm install
npm run build

# Setup systemd service for WebUI with binding to all interfaces
echo "Creating systemd service for WebUI..."
cat > /etc/systemd/system/open5gs-webui.service << EOF
[Unit]
Description=Open5GS WebUI
After=network.target mongodb.service

[Service]
WorkingDirectory=/opt/open5gs-webui
ExecStart=/usr/bin/npm run start
Restart=always
User=root
Group=root
Environment=NODE_ENV=production
Environment=HOSTNAME=0.0.0.0
Environment=PORT=3000

[Install]
WantedBy=multi-user.target
EOF

# Enable and start services
echo "Starting services..."
systemctl daemon-reload
systemctl enable open5gs-webui
systemctl start open5gs-webui

# Enable Open5GS services
for SERVICE in nrf amf smf upf ausf udm pcf nssf bsf udr; do
    systemctl enable open5gs-${SERVICE}d
    systemctl restart open5gs-${SERVICE}d
done

# Create admin user for WebUI
echo "Creating default admin user for WebUI..."
cat > /tmp/create_admin.js << EOF
db = db.getSiblingDB('open5gs');
db.accounts.update(
  { "username" : "admin" },
  { "\$set" : { "username" : "admin", "roles" : [ "admin" ], "password" : "\$2b\$10\$Ix6Xb9XN7KsPtRlDRgKQnuRmYbOYTxCwgwrXIGk/42Z5SY8MuOIJi" } },
  { upsert: true }
);
EOF

mongo < /tmp/create_admin.js
rm /tmp/create_admin.js

echo "Open5GS installation completed at $(date)"
echo "WebUI is available at http://$(hostname -I | awk '{print $1}'):3000"
echo "Default WebUI credentials: admin / 1423" 