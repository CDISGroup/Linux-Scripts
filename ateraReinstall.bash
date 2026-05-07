#!/bin/bash

: '
.SYNOPSIS
    Atera Agent Clean Reinstall Script (Linux)

.DESCRIPTION
    This script:
    1. Stops and disables any existing Atera agent service
    2. Kills any running Atera-related processes
    3. Removes all known Atera installation directories and data
    4. Removes the Atera system user if present
    5. Reloads systemd to clean up stale service entries
    6. Downloads and installs the Atera agent using predefined URL
    7. Verifies the agent service status and outputs recent logs

.NOTES
    Must be run with sudo/root privileges
    Only been tested on Linux Mint
    Verify that the Install command is up to date before using
    Version: 1.1 - Last Updated on 07/05/2026

.AUTHOR
    Kajay
'

echo "=== Atera Agent Clean Reinstall Script ==="
echo ""

# Step 1: Stop and disable existing service
echo "[1/7] Stopping existing Atera service..."
sudo systemctl stop atera-agent 2>/dev/null || true
sudo systemctl disable atera-agent 2>/dev/null || true

# Step 2: Kill any running Atera processes
echo "[2/7] Killing any running Atera processes..."
sudo pkill -f -i atera 2>/dev/null || true

# Step 3: Remove installation directories and data
echo "[3/7] Removing Atera files and directories..."
sudo rm -rf /opt/AteraAgent
sudo rm -rf /opt/atera-agent
sudo rm -rf /var/lib/atera-agent
sudo rm -rf /etc/atera-agent

# Step 4: Remove Atera system user if it exists
echo "[4/7] Removing Atera system user (if present)..."
sudo userdel atera 2>/dev/null || true

# Step 5: Reload systemd and clean failed states
echo "[5/7] Reloading systemd..."
sudo systemctl daemon-reload
sudo systemctl reset-failed

# Step 6: Install Atera agent
echo "[6/7] Installing Atera agent..."
wget -O - "https://cdis.servicedesk.atera.com/api/utils/agent-install-script/linux/c2d374cc1bc54d35a64fee21f2725096?customerId=36" | sudo bash

# Step 7: Validate installation
echo ""
echo "[7/7] Checking service status..."
sudo systemctl status atera-agent --no-pager || true

echo ""
echo "Recent Atera logs:"
sudo journalctl -u atera-agent -n 50 --no-pager || true

echo ""
echo "=== Complete ==="
echo "Device should reappear on Atera Dashboard shortly. "