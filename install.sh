#!/bin/bash

# Speedtest Monitoring Installation Script
# This script helps you set up speedtest monitoring on your system

set -e

echo "=========================================="
echo "  Speedtest Monitoring - Installation"
echo "=========================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "Cannot detect OS. Please install manually."
    exit 1
fi

echo "Detected OS: $OS"
echo ""

# Install dependencies
echo "Installing dependencies..."
case $OS in
    ubuntu|debian)
        apt-get update
        apt-get install -y curl jq bc
        
        # Install Speedtest CLI
        if ! command -v speedtest &> /dev/null; then
            echo "Installing Speedtest CLI..."
            curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash
            apt-get install -y speedtest
        fi
        
        # Install web server
        if ! command -v nginx &> /dev/null && ! command -v apache2 &> /dev/null; then
            echo "No web server found. Installing nginx..."
            apt-get install -y nginx
            systemctl enable nginx
            systemctl start nginx
            WEB_ROOT="/var/www/html"
        elif command -v nginx &> /dev/null; then
            WEB_ROOT="/var/www/html"
        else
            WEB_ROOT="/var/www/html"
        fi
        ;;
    centos|rhel|fedora)
        yum install -y curl jq bc
        
        # Install Speedtest CLI
        if ! command -v speedtest &> /dev/null; then
            echo "Installing Speedtest CLI..."
            curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.rpm.sh | bash
            yum install -y speedtest
        fi
        
        # Install web server
        if ! command -v nginx &> /dev/null && ! command -v httpd &> /dev/null; then
            echo "No web server found. Installing nginx..."
            yum install -y nginx
            systemctl enable nginx
            systemctl start nginx
            WEB_ROOT="/usr/share/nginx/html"
        elif command -v nginx &> /dev/null; then
            WEB_ROOT="/usr/share/nginx/html"
        else
            WEB_ROOT="/var/www/html"
        fi
        ;;
    *)
        echo "Unsupported OS. Please install dependencies manually:"
        echo "  - Speedtest CLI: https://www.speedtest.net/apps/cli"
        echo "  - jq: https://stedolan.github.io/jq/"
        echo "  - bc: basic calculator"
        exit 1
        ;;
esac

echo "Dependencies installed successfully!"
echo ""

# Get installation directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$WEB_ROOT/speedtest"

echo "Installation directory: $INSTALL_DIR"

# Create directory
mkdir -p "$INSTALL_DIR"

# Copy files
echo "Copying files..."
cp "$SCRIPT_DIR/index.html" "$INSTALL_DIR/"
cp "$SCRIPT_DIR/cronjob.sh" "$INSTALL_DIR/"
cp "$SCRIPT_DIR/config.example.json" "$INSTALL_DIR/config.json"

# Update config file
echo "Configuring..."
sed -i "s|/var/www/html/speedtest|$INSTALL_DIR|g" "$INSTALL_DIR/config.json"

# Make script executable
chmod +x "$INSTALL_DIR/cronjob.sh"

# Initialize results file
echo "[]" > "$INSTALL_DIR/results.json"
chmod 666 "$INSTALL_DIR/results.json"

# Set up cron job
echo ""
echo "Setting up cron job..."
read -r -p "How often should speed tests run? (1=hourly, 2=every 30min, 3=every 15min, 4=custom): " FREQ

case $FREQ in
    1)
        CRON_SCHEDULE="0 * * * *"
        ;;
    2)
        CRON_SCHEDULE="*/30 * * * *"
        ;;
    3)
        CRON_SCHEDULE="*/15 * * * *"
        ;;
    4)
        read -r -p "Enter cron schedule (e.g., '0 * * * *' for hourly): " CRON_SCHEDULE
        ;;
    *)
        CRON_SCHEDULE="0 * * * *"
        echo "Using default: hourly"
        ;;
esac

# Add to crontab
CRON_JOB="$CRON_SCHEDULE $INSTALL_DIR/cronjob.sh >> /var/log/speedtest.log 2>&1"
(crontab -l 2>/dev/null | grep -v "cronjob.sh"; echo "$CRON_JOB") | crontab -

echo ""
echo "=========================================="
echo "  Installation Complete!"
echo "=========================================="
echo ""
echo "Configuration:"
echo "  - Installation directory: $INSTALL_DIR"
echo "  - Cron schedule: $CRON_SCHEDULE"
echo "  - Log file: /var/log/speedtest.log"
echo ""
echo "Next steps:"
echo "  1. Edit $INSTALL_DIR/config.json to customize settings"
echo "  2. Run first test: $INSTALL_DIR/cronjob.sh"
echo "  3. Access dashboard: http://$(hostname -I | awk '{print $1}')/speedtest/"
echo ""
echo "To view logs: tail -f /var/log/speedtest.log"
echo "To modify cron: crontab -e"
echo ""
