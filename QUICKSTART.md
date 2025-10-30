# Quick Start Guide

Get up and running with Speedtest Monitoring in 5 minutes!

## Prerequisites

- Linux/Unix system
- Root/sudo access

## Installation (Automated)

```bash
# Clone the repository
git clone https://github.com/markchristianlacap/speedtest-monitoring.git
cd speedtest-monitoring

# Run the installation script
sudo ./install.sh
```

The script will:
1. Install all dependencies (speedtest CLI, jq, web server)
2. Set up the application
3. Configure a cron job
4. Start the web server

## Manual Installation (5 Steps)

### 1. Install Dependencies

**Ubuntu/Debian:**
```bash
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
sudo apt-get install speedtest jq nginx
```

**CentOS/RHEL:**
```bash
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.rpm.sh | sudo bash
sudo yum install speedtest jq nginx
```

### 2. Set Up Files

```bash
# Create directory
sudo mkdir -p /var/www/html/speedtest

# Copy files
sudo cp index.html config.json /var/www/html/speedtest/

# Initialize results
echo "[]" | sudo tee /var/www/html/speedtest/results.json

# Set permissions
sudo chmod 666 /var/www/html/speedtest/results.json
```

### 3. Configure Cron Job

```bash
# Make script executable
chmod +x cronjob.sh

# Add to crontab (runs every hour)
crontab -e
```

Add this line:
```
0 * * * * /path/to/speedtest-monitoring/cronjob.sh >> /var/log/speedtest.log 2>&1
```

### 4. Run First Test

```bash
./cronjob.sh
```

### 5. Access Dashboard

Open your browser to: `http://your-server-ip/speedtest/`

## Docker Installation

Even faster with Docker!

```bash
# Clone repository
git clone https://github.com/markchristianlacap/speedtest-monitoring.git
cd speedtest-monitoring

# Start with Docker Compose
docker-compose up -d

# Access at http://localhost:8080/speedtest/
```

## Verification

Check that everything works:

```bash
# View logs
tail -f /var/log/speedtest.log

# Check results file
cat /var/www/html/speedtest/results.json

# Verify cron job
crontab -l | grep speedtest
```

## Customization

Edit `config.json` to customize:
- Location name
- Output path
- Maximum results to keep

## Troubleshooting

**No data showing?**
```bash
# Run test manually
./cronjob.sh

# Check for errors
tail /var/log/speedtest.log
```

**Permission denied?**
```bash
sudo chmod 666 /var/www/html/speedtest/results.json
```

**Speedtest not found?**
```bash
# Verify installation
speedtest --version
which speedtest
```

## Next Steps

- Adjust test frequency in crontab
- Set up backup for results.json
- Consider adding alerts for slow speeds
- Explore the full [README](README.md) for more features

## Getting Help

- Check the [README](README.md)
- Open an [issue](https://github.com/markchristianlacap/speedtest-monitoring/issues)
- Read [CONTRIBUTING.md](CONTRIBUTING.md)
