# Hosted Cloud Core

Cloud-init configuration for easy provisioning of Open5GS-based EPC/5GC virtual machines.

## Overview

This repository provides cloud-init scripts to automatically configure and install Open5GS (an open-source implementation of 4G EPC and 5G core network) on virtual machines at boot time. Cloud-init is the industry standard for initializing cloud instances across most major cloud providers.

## What's Included

The cloud-init configuration automatically installs and configures:
- Open5GS core network components (4G EPC and 5G core)
- IPsec gateway for secure eNodeB/gNodeB connections
- Open5GS WebUI for network management
- Web interface for easier configuration

## Compatibility

The cloud-init configuration has only been tested on Ubuntu 22.04 LTS.

## How to Use

### Step 1: Access your cloud provider's console

Sign in to your cloud provider (AWS, GCP, Azure, DigitalOcean, etc.) and start the VM creation process.

### Step 2: Provide the cloud-init script as user data

When creating your virtual machine, look for a section called:
- Vultr: "Cloud-Init User-Data" under the "Additional Features" section
<!-- - DigitalOcean: "User data" under "Add initialization script" -->

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
  - chmod +x /tmp/hosted-cloud-core/install-cloud-core.sh
  - /tmp/hosted-cloud-core/install-cloud-core.sh > /var/log/cloud-core-install.log 2>&1 
```

### Step 4: Access your server

Wait approximately 15 minutes for installation to complete, then access `http://server_ip` in your browser. You should see the dashboard and settings interface for your femto devices.

## Recommended Cloud Provider

We recommend [Vultr](https://www.vultr.com/?ref=9746929-9J) for deploying your Open5GS instances. Vultr offers:

- Global footprint with 32 data center regions
- Affordable cloud compute options starting at $2.50/month
- High-performance infrastructure with excellent price-to-performance ratio
- Easy-to-use control panel for managing your instances
- Fast deployment (under 60 seconds for many VM types)

You can sign up for Vultr using our [referral link](https://www.vultr.com/?ref=9746929-9J). **New users receive a $300 credit to test the platform when signing up through this link!**

