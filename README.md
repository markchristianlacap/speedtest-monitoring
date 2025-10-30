# 📶 Speedtest Monitoring

A lightweight, self-hosted internet speed monitoring tool that automatically runs speed tests and visualizes the results over time.

![Screenshot](https://img.shields.io/badge/vue.js-3.x-brightgreen) ![Screenshot](https://img.shields.io/badge/chart.js-latest-blue)

## Features

- 🚀 Automatic speed testing via cron job
- 📊 Interactive charts showing download/upload speeds over time
- 📅 Date range filtering
- 📱 Responsive design
- 🎯 Simple single-page application (no backend required)
- 🔄 Real-time data updates
- 📈 Historical data tracking

## Prerequisites

- Linux/Unix system (Ubuntu, Debian, CentOS, etc.)
- [Speedtest CLI](https://www.speedtest.net/apps/cli) by Ookla
- `jq` - Command-line JSON processor
- Web server (Apache, Nginx, or any HTTP server)
- `cron` or `systemd` timer for scheduling

## Installation

### 1. Install Speedtest CLI

**Ubuntu/Debian:**
```bash
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
sudo apt-get install speedtest
```

**CentOS/RHEL:**
```bash
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.rpm.sh | sudo bash
sudo yum install speedtest
```

**macOS:**
```bash
brew install speedtest-cli
```

### 2. Install jq

**Ubuntu/Debian:**
```bash
sudo apt-get install jq
```

**CentOS/RHEL:**
```bash
sudo yum install jq
```

**macOS:**
```bash
brew install jq
```

### 3. Clone the Repository

```bash
git clone https://github.com/markchristianlacap/speedtest-monitoring.git
cd speedtest-monitoring
```

### 4. Configure the Application

Create a configuration file:

```bash
cp config.example.json config.json
```

Edit `config.json` to customize:
- Location name/title
- Output directory path
- Test interval settings

### 5. Set Up the Web Server

**Option A: Using Apache**
```bash
# Copy files to web root
sudo mkdir -p /var/www/html/speedtest
sudo cp index.html /var/www/html/speedtest/
sudo cp config.json /var/www/html/speedtest/
sudo touch /var/www/html/speedtest/results.json
sudo chmod 666 /var/www/html/speedtest/results.json
```

**Option B: Using Nginx**
```bash
# Copy files to web root
sudo mkdir -p /usr/share/nginx/html/speedtest
sudo cp index.html /usr/share/nginx/html/speedtest/
sudo cp config.json /usr/share/nginx/html/speedtest/
sudo touch /usr/share/nginx/html/speedtest/results.json
sudo chmod 666 /usr/share/nginx/html/speedtest/results.json
```

**Option C: Using Docker**
```bash
docker-compose up -d
```

### 6. Set Up the Cron Job

Make the script executable:
```bash
chmod +x cronjob.sh
```

Edit the script to set your web root path:
```bash
nano cronjob.sh
```

Add to crontab (runs every hour):
```bash
crontab -e
```

Add this line:
```
0 * * * * /path/to/speedtest-monitoring/cronjob.sh >> /var/log/speedtest.log 2>&1
```

Or for every 30 minutes:
```
*/30 * * * * /path/to/speedtest-monitoring/cronjob.sh >> /var/log/speedtest.log 2>&1
```

### 7. Run Initial Test

Run the script manually to verify it works:
```bash
./cronjob.sh
```

Check the results:
```bash
cat /var/www/html/speedtest/results.json
```

## Usage

1. Open your browser and navigate to: `http://your-server-ip/speedtest/`
2. The dashboard will display:
   - A line chart showing download and upload speeds over time
   - A data table with detailed test results
   - Date filters to focus on specific time periods
3. Use the date filters to view historical data
4. Click "View" links to see detailed results on Speedtest.net

## Configuration

The `config.json` file allows you to customize:

```json
{
  "title": "Main Campus - Speedtest Monitoring",
  "location": "OMSC Main",
  "outputPath": "/var/www/html/speedtest/results.json",
  "maxResults": 10000,
  "timezone": "Asia/Manila"
}
```

- `title`: Page title displayed in browser
- `location`: Location name shown in dashboard
- `outputPath`: Where to store results.json
- `maxResults`: Maximum number of results to keep (older results are removed)
- `timezone`: Timezone for displaying dates

## File Structure

```
speedtest-monitoring/
├── index.html          # Web dashboard
├── cronjob.sh         # Speed test automation script
├── config.json        # Configuration file
├── config.example.json # Example configuration
├── docker-compose.yml # Docker deployment
├── Dockerfile         # Docker image definition
├── .gitignore         # Git ignore rules
├── LICENSE            # License information
└── README.md          # This file
```

## Troubleshooting

### Speed test not running
- Verify Speedtest CLI is installed: `speedtest --version`
- Check cron is running: `systemctl status cron`
- Check log file: `tail -f /var/log/speedtest.log`

### Web page shows no data
- Verify `results.json` exists and has data
- Check file permissions: `ls -l /var/www/html/speedtest/results.json`
- Check browser console for errors (F12)

### Permission denied errors
```bash
sudo chmod 666 /var/www/html/speedtest/results.json
```

### JSON parsing errors
- Verify JSON is valid: `jq . /var/www/html/speedtest/results.json`
- If corrupted, reset: `echo "[]" > /var/www/html/speedtest/results.json`

## Customization

### Change Chart Colors
Edit `index.html` and modify the `borderColor` values in the Chart.js configuration:
```javascript
borderColor: 'red',  // Download color
borderColor: 'blue', // Upload color
```

### Change Test Frequency
Edit your crontab entry. Examples:
- Every 15 minutes: `*/15 * * * *`
- Every 2 hours: `0 */2 * * *`
- Daily at 8 AM: `0 8 * * *`

### Add Email Alerts
Modify `cronjob.sh` to send email when speeds drop below threshold:
```bash
DOWNLOAD=$(echo "$RESULT" | jq -r '.download.bandwidth')
if (( $(echo "$DOWNLOAD < 10000000" | bc -l) )); then
    echo "Slow download speed detected" | mail -s "Speed Alert" admin@example.com
fi
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Security Considerations

- The `results.json` file is publicly accessible if placed in web root
- Consider adding authentication if monitoring sensitive networks
- Regularly backup your results data
- Limit file permissions to prevent unauthorized access

## Performance Tips

- Set `maxResults` in config to limit JSON file size
- Archive old results periodically
- Use a reverse proxy with caching for better performance
- Consider rate limiting if publicly accessible

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Credits

- [Speedtest CLI](https://www.speedtest.net/apps/cli) by Ookla
- [Chart.js](https://www.chartjs.org/) for data visualization
- [Vue.js](https://vuejs.org/) for reactive UI
- [UnoCSS](https://unocss.dev/) for styling

## Roadmap

- [ ] Add multiple location support
- [ ] Email/SMS alerts for speed drops
- [ ] Export data to CSV/PDF
- [ ] Mobile app
- [ ] API endpoint for external integrations
- [ ] Database backend option
- [ ] User authentication
- [ ] Speed test comparison with ISP advertised speeds

## Support

If you encounter any issues or have questions:
- Open an [Issue](https://github.com/markchristianlacap/speedtest-monitoring/issues)
- Check existing issues for solutions
- Review the [Troubleshooting](#troubleshooting) section

## Changelog

### v1.0.0 (Initial Release)
- Basic speed test monitoring
- Chart visualization
- Date filtering
- Cron automation
