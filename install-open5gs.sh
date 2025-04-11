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

# Install Node.js for WebUI
echo "Installing Node.js for WebUI..."
apt-get install -y curl
curl -sL https://deb.nodesource.com/setup_16.x | bash -
apt-get install -y nodejs

# Install WebUI using the official method
echo "Installing Open5GS WebUI..."
curl -fsSL https://open5gs.org/open5gs/assets/webui/install | bash -

# Enable Open5GS services
for SERVICE in nrf amf smf upf ausf udm pcf nssf bsf udr; do
    systemctl enable open5gs-${SERVICE}d
    systemctl restart open5gs-${SERVICE}d
done

echo "Open5GS installation completed at $(date)"
echo "WebUI is available at http://$(hostname -I | awk '{print $1}'):3000"
echo "Default WebUI credentials: admin / 1423" 