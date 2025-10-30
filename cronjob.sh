#!/bin/bash

# Speedtest Monitoring Cron Script
# This script runs a speedtest and appends the result to a JSON file

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config.json"
DEFAULT_OUTPUT="/var/www/html/speedtest/results.json"
DEFAULT_LOG="/var/log/speedtest.log"
DEFAULT_MAX_RESULTS=10000

# Load configuration if available
if [ -f "$CONFIG_FILE" ]; then
    OUTPUT_FILE=$(jq -r '.outputPath // empty' "$CONFIG_FILE" 2>/dev/null || echo "")
    LOG_FILE=$(jq -r '.logFile // empty' "$CONFIG_FILE" 2>/dev/null || echo "")
    MAX_RESULTS=$(jq -r '.maxResults // empty' "$CONFIG_FILE" 2>/dev/null || echo "")
else
    OUTPUT_FILE=""
    LOG_FILE=""
    MAX_RESULTS=""
fi

# Use defaults if not configured
OUTPUT_FILE="${OUTPUT_FILE:-$DEFAULT_OUTPUT}"
LOG_FILE="${LOG_FILE:-$DEFAULT_LOG}"
MAX_RESULTS="${MAX_RESULTS:-$DEFAULT_MAX_RESULTS}"

# Logging function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE" 2>/dev/null || echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

# Error handling function
error_exit() {
    log "ERROR: $1"
    exit 1
}

# Check if required commands exist
command -v speedtest >/dev/null 2>&1 || error_exit "speedtest CLI is not installed. Please install it first."
command -v jq >/dev/null 2>&1 || error_exit "jq is not installed. Please install it first."

log "Starting speedtest..."

# Run speedtest with timeout
RESULT=""
if ! RESULT=$(timeout 120 speedtest --format=json 2>&1); then
    error_exit "Speedtest failed or timed out: $RESULT"
fi

# Validate JSON output
if ! echo "$RESULT" | jq empty 2>/dev/null; then
    error_exit "Speedtest did not return valid JSON: $RESULT"
fi

log "Speedtest completed successfully"

# Create output directory if it doesn't exist
OUTPUT_DIR=$(dirname "$OUTPUT_FILE")
if [ ! -d "$OUTPUT_DIR" ]; then
    log "Creating output directory: $OUTPUT_DIR"
    mkdir -p "$OUTPUT_DIR" || error_exit "Failed to create output directory: $OUTPUT_DIR"
fi

# Initialize results file if it doesn't exist
if [ ! -f "$OUTPUT_FILE" ]; then
    log "Initializing results file: $OUTPUT_FILE"
    echo "[]" > "$OUTPUT_FILE" || error_exit "Failed to create results file: $OUTPUT_FILE"
fi

# Backup current results before modification
BACKUP_FILE="${OUTPUT_FILE}.backup"
cp "$OUTPUT_FILE" "$BACKUP_FILE" || log "Warning: Failed to create backup"

# Append new result
if ! jq ". += [$RESULT]" "$OUTPUT_FILE" > "${OUTPUT_FILE}.tmp"; then
    log "Error: Failed to append result, restoring backup"
    mv "$BACKUP_FILE" "$OUTPUT_FILE"
    error_exit "Failed to append speedtest result"
fi

# Trim results if exceeding max limit
RESULT_COUNT=$(jq '. | length' "${OUTPUT_FILE}.tmp")
if [ "$RESULT_COUNT" -gt "$MAX_RESULTS" ]; then
    log "Trimming results from $RESULT_COUNT to $MAX_RESULTS"
    TRIM_COUNT=$((RESULT_COUNT - MAX_RESULTS))
    jq ".[$TRIM_COUNT:]" "${OUTPUT_FILE}.tmp" > "${OUTPUT_FILE}.trimmed" && mv "${OUTPUT_FILE}.trimmed" "${OUTPUT_FILE}.tmp"
fi

# Replace original file
mv "${OUTPUT_FILE}.tmp" "$OUTPUT_FILE" || error_exit "Failed to update results file"

# Remove backup on success
rm -f "$BACKUP_FILE"

# Log success with stats
DOWNLOAD=$(echo "$RESULT" | jq -r '.download.bandwidth')
UPLOAD=$(echo "$RESULT" | jq -r '.upload.bandwidth')
PING=$(echo "$RESULT" | jq -r '.ping.latency')

# Convert to Mbps
DOWNLOAD_MBPS=$(echo "scale=2; ($DOWNLOAD * 8) / 1000000" | bc)
UPLOAD_MBPS=$(echo "scale=2; ($UPLOAD * 8) / 1000000" | bc)

log "Result: Download=${DOWNLOAD_MBPS}Mbps Upload=${UPLOAD_MBPS}Mbps Ping=${PING}ms"
log "Total results stored: $(jq '. | length' "$OUTPUT_FILE")"

exit 0
