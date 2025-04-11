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
- AWS: "User data" under the "Advanced details" section
- GCP: "Startup script" or "Automation" section
- Azure: "Custom data" under the "Advanced" tab
- DigitalOcean: "User data" under "Add initialization script"

### Step 3: Copy and paste the cloud-init script

Copy the contents of `cloud-init.yaml` from this repository and paste it into the user data/custom data field.

### Step 4: Customize as needed

Before submitting, modify the script as needed:
- Add or remove packages according to your requirements
- Adjust any other settings to match your needs

### Step 5: Create the VM

Complete the VM creation process according to your cloud provider's instructions.

### Step 6: Access Open5GS WebUI

Once the VM is ready, you can access the Open5GS WebUI at:

```
http://YOUR_VM_IP:3000
```

Default login credentials:
- Username: admin
- Password: 1423

## Open5GS Components

This installation includes:
- Core Network Functions (NRF, AMF, SMF, UPF, AUSF, UDM, PCF, NSSF, BSF, UDR)
- WebUI for administration
- MongoDB for subscriber database