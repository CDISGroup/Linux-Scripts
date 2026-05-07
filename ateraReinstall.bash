#!/bin/bash

: '
.SYNOPSIS
    Atera Agent and Splashtop Clean Reinstall Script (Linux)

.DESCRIPTION
    This script:
    1. Stops and disables the existing Atera agent service
    2. Stops the existing Splashtop Streamer service
    3. Kills any running Atera or Splashtop processes
    4. Removes known Atera installation directories and data
    5. Removes known Splashtop Streamer installation directories and data
    6. Removes the Atera system user if present
    7. Reloads systemd to clean up stale service entries
    8. Reinstalls the Atera agent using the predefined install URL
    9. Checks Atera and Splashtop service status/logs

.NOTES
    Must be run with sudo/root privileges
    Designed for Debian-based systems (Linux Mint / Ubuntu)
    Splashtop should be redeployed by Atera after the agent is online
    Version: 1.2
'

echo "=== Atera Agent and Splashtop Clean Reinstall Script ==="
echo ""

# Step 1: Stop and disable existing Atera service
echo "[1/9] Stopping existing Atera service..."
sudo systemctl stop atera-agent 2>/dev/null || true
sudo systemctl disable atera-agent 2>/dev/null || true

# Step 2: Stop existing Splashtop service
echo "[2/9] Stopping existing Splashtop service..."
sudo systemctl stop SRStreamer 2>/dev/null || true
sudo systemctl disable SRStreamer 2>/dev/null || true

# Step 3: Kill any running Atera or Splashtop processes
echo "[3/9] Killing running Atera/Splashtop processes..."
sudo pkill -f -i atera 2>/dev/null || true
sudo pkill -f -i splashtop 2>/dev/null || true
sudo pkill -f -i SRStreamer 2>/dev/null || true

# Step 4: Remove Atera files and directories
echo "[4/9] Removing Atera files and directories..."
sudo rm -rf /opt/AteraAgent
sudo rm -rf /opt/atera-agent
sudo rm -rf /var/lib/atera-agent
sudo rm -rf /etc/atera-agent

# Step 5: Remove Splashtop files and directories
echo "[5/9] Removing Splashtop files and directories..."
sudo rm -rf /opt/splashtop-streamer
sudo rm -rf /var/lib/splashtop-streamer
sudo rm -rf /etc/splashtop-streamer

# Step 6: Remove Atera system user if it exists
echo "[6/9] Removing Atera system user if present..."
sudo userdel atera 2>/dev/null || true

# Step 7: Reload systemd and clean failed states
echo "[7/9] Reloading systemd..."
sudo systemctl daemon-reload
sudo systemctl reset-failed

# Step 8: Reinstall Atera agent
echo "[8/9] Installing Atera agent..."
wget -O - "https://cdis.servicedesk.atera.com/api/utils/agent-install-script/linux/c2d374cc1bc54d35a64fee21f2725096?customerId=36" | sudo bash

# Step 9: Validate installation
echo ""
echo "[9/9] Checking service status..."

echo ""
echo "Atera Agent status:"
sudo systemctl status atera-agent --no-pager || true

echo ""
echo "Splashtop Streamer status:"
sudo systemctl status SRStreamer --no-pager || true

echo ""
echo "Recent Atera logs:"
sudo journalctl -u atera-agent -n 30 --no-pager || true

echo ""
echo "Recent Splashtop logs:"
sudo journalctl -u SRStreamer -n 30 --no-pager || true

echo ""
echo "=== Complete ==="
echo "Atera should come online first. Then redeploy Splashtop from Atera if it does not reinstall automatically."