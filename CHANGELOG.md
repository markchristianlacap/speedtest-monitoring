# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2024-10-30

### Added
- **Documentation**
  - Comprehensive README.md with 300+ lines covering installation, usage, troubleshooting, and customization
  - QUICKSTART.md for fast 5-minute setup
  - CONTRIBUTING.md with contributor guidelines
  - MIT LICENSE for open-source distribution
  - This CHANGELOG.md to track changes

- **Configuration System**
  - `config.json` for centralized configuration
  - `config.example.json` as template
  - Support for customizable title, location name, output path, max results, timezone, and log file location
  - Dynamic configuration loading in web interface

- **DevOps & Deployment**
  - `Dockerfile` for containerized deployment
  - `docker-compose.yml` for one-command setup
  - `install.sh` - automated installation script with OS detection (Ubuntu/Debian/CentOS/RHEL)
  - Sample data file `results.example.json` for testing

### Enhanced
- **cronjob.sh** (9 lines → 100+ lines)
  - Comprehensive error handling and validation
  - Automatic backup system before modifications
  - Timestamped logging
  - Configuration file support
  - Results trimming to prevent unlimited growth
  - Timeout protection (120 seconds)
  - Dependency checking (speedtest CLI, jq)
  - Success statistics logging (Download/Upload/Ping in Mbps)
  - Recovery mechanism on failure
  - Passes shellcheck validation

- **index.html** (150 lines → 350+ lines)
  - Loading states with animated spinner
  - Comprehensive error handling with user-friendly messages
  - Statistics cards showing average/min/max for download/upload/ping
  - Manual refresh button
  - Improved responsive design for mobile devices
  - Configuration support (dynamic title and location)
  - Enhanced chart styling with filled areas and better colors
  - Improved table formatting with hover effects
  - Footer with credits and GitHub link
  - Viewport meta tag for mobile optimization
  - Better date filtering logic (includes full day range)
  - Result count display

- **.gitignore**
  - Expanded to exclude backup files (*.backup)
  - Exclude temporary files (*.tmp)
  - Exclude log files (*.log)
  - Exclude config.json (user-specific)
  - Exclude system files (.DS_Store, *.swp, *.swo, *~)
  - Exclude node_modules and .env files

### Fixed
- Date filtering now includes the full day (00:00:00 to 23:59:59)
- Proper error messages when results.json is missing or invalid
- Shell script now handles missing dependencies gracefully
- JSON parsing errors are caught and logged

### Security
- Backup system prevents data loss
- Input validation for JSON data
- File permission checks
- Timeout protection prevents hanging processes
- Error recovery mechanisms

### Technical
- All shell scripts pass shellcheck validation
- All JSON files validated
- HTML structure validated
- Code follows best practices
- Comprehensive error handling throughout

## [0.1.0] - Initial Prototype

### Initial Release
- Basic speedtest monitoring functionality
- Simple cron script to run speedtest
- Basic HTML interface with Vue.js
- Chart visualization with Chart.js
- Date filtering capability
- Hardcoded configuration
- No error handling
- No documentation
