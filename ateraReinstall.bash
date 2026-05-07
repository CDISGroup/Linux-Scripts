#!/bin/bash

: '
.SYNOPSIS
    Atera Agent and Splashtop Clean Reinstall Script (Linux)

.DESCRIPTION
    This script:
    1. Stops the existing Atera Agent service
    2. Stops the existing Splashtop Streamer service
    3. Kills known Atera and Splashtop processes safely
    4. Removes known Atera files and directories
    5. Removes known Splashtop files, directories, and service files
    6. Removes the Atera system user if present
    7. Reloads systemd and clears failed service states
    8. Reinstalls the Atera Agent using the predefined install URL
    9. Checks the correct Atera service status

.NOTES
    Must be run with sudo/root privileges
    Designed for Debian-based systems, including Linux Mint / Ubuntu
    Splashtop should be redeployed from Atera after the Atera Agent is online
    Version: 1.3
'

echo "=== Atera Agent and Splashtop Clean Reinstall Script ==="
echo ""

# Step 1: Stop and disable existing Atera services
echo "[1/9] Stopping existing Atera services..."
sudo systemctl stop AteraAgent 2>/dev/null || true
sudo systemctl disable AteraAgent 2>/dev/null || true
sudo systemctl stop atera-agent 2>/dev/null || true
sudo systemctl disable atera-agent 2>/dev/null || true

# Step 2: Stop and disable existing Splashtop service
echo "[2/9] Stopping existing Splashtop service..."
sudo systemctl stop SRStreamer 2>/dev/null || true
sudo systemctl disable SRStreamer 2>/dev/null || true

# Step 3: Kill known Atera/Splashtop processes safely
echo "[3/9] Killing running Atera/Splashtop processes..."
sudo pkill -f "/opt/AteraAgent" 2>/dev/null || true
sudo pkill -f "/opt/atera-agent" 2>/dev/null || true
sudo pkill -f "/usr/lib/atera-agent" 2>/dev/null || true
sudo pkill -f "/opt/splashtop-streamer" 2>/dev/null || true
sudo pkill -f "SRStreamer" 2>/dev/null || true
sudo pkill -f "SRFeature" 2>/dev/null || true
sudo pkill -f "SRAgent" 2>/dev/null || true

# Step 4: Remove Atera files and directories
echo "[4/9] Removing Atera files and directories..."
sudo rm -rf /opt/AteraAgent
sudo rm -rf /opt/atera-agent
sudo rm -rf /usr/lib/atera-agent
sudo rm -rf /var/lib/atera-agent
sudo rm -rf /etc/atera-agent
sudo rm -f /etc/systemd/system/AteraAgent.service
sudo rm -f /etc/systemd/system/atera-agent.service
sudo rm -f /usr/lib/systemd/system/AteraAgent.service
sudo rm -f /usr/lib/systemd/system/atera-agent.service

# Step 5: Remove Splashtop files, directories, and service files
echo "[5/9] Removing Splashtop files, directories, and service files..."
sudo rm -rf /opt/splashtop-streamer
sudo rm -rf /var/lib/splashtop-streamer
sudo rm -rf /etc/splashtop-streamer
sudo rm -f /usr/lib/systemd/system/SRStreamer.service
sudo rm -f /etc/systemd/system/SRStreamer.service

# Step 6: Remove Atera system user if it exists
echo "[6/9] Removing Atera system user if present..."
sudo userdel atera 2>/dev/null || true

# Step 7: Reload systemd and clear failed states
echo "[7/9] Reloading systemd..."
sudo systemctl daemon-reload
sudo systemctl reset-failed

# Step 8: Install Atera Agent
echo "[8/9] Installing Atera Agent..."
wget -O - "https://cdis.servicedesk.atera.com/api/utils/agent-install-script/linux/c2d374cc1bc54d35a64fee21f2725096?customerId=36" | sudo bash

# Step 9: Validate installation
echo ""
echo "[9/9] Checking service status..."

echo ""
echo "Atera Agent status:"
sudo systemctl status AteraAgent --no-pager || true

echo ""
echo "Checking for leftover Splashtop service:"
systemctl list-units --type=service --all | grep -i splashtop || echo "No Splashtop service found. Redeploy Splashtop from Atera."

echo ""
echo "Recent Atera logs:"
sudo journalctl -u AteraAgent -n 30 --no-pager || true

echo ""
echo "=== Complete ==="
echo "Atera should come online first. Redeploy Splashtop from Atera after the device is visible."