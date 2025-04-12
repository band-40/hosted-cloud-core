# Hosted Cloud Core

Cloud-init configuration for easy provisioning of Open5GS-based EPC/5GC virtual machines.

## Overview

This repository provides cloud-init scripts to automatically configure and install Open5GS (an open-source implementation of 4G EPC and 5G core network) on virtual machines at boot time. Cloud-init is the industry standard for initializing cloud instances across most major cloud providers.

## What's Included

The default cloud-init configuration:
- Updates and upgrades system packages
- Installs essential software (nginx, git, curl, wget)
- Creates a default user with sudo privileges
- Installs Open5GS core network components and WebUI
- Runs a simple initialization script

## How to Use

### Step 1: Access your cloud provider's console

Sign in to your cloud provider (AWS, GCP, Azure, DigitalOcean, etc.) and start the VM creation process.

### Step 2: Provide the cloud-init script as user data

When creating your virtual machine, look for a section called:
- Vultr: "Cloud-Init" under the "Startup Scripts" section
- DigitalOcean: "User data" under "Add initialization script"

### Step 3: Copy the following cloud-init script

```
#cloud-config

# Update and upgrade packages
package_update: true
package_upgrade: true

# Install minimal required packages
packages:
  - git
  - curl

# Run commands on first boot
runcmd:
  - git clone https://github.com/band-40/hosted-cloud-core.git /tmp/hosted-cloud-core
  - chmod +x /tmp/hosted-cloud-core/install-open5gs.sh
  - /tmp/hosted-cloud-core/install-open5gs.sh > /var/log/open5gs-install.log 2>&1 
```


### Step 4: Wait for ~15mins, access the server ip http://server_ip, you should see the dashboard and settings for femto devices.

