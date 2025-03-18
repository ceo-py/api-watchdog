#!/bin/bash

# API Health Check Script
# This script checks if the API is responding correctly
# and restarts the service if necessary

# Configuration
API_URL="URL OF API"
SERVICE_NAME="SERVICE NAME TO RESTART"
LOG_FILE="LOG FILE LOCATION"
TIMEOUT=10  # Timeout in seconds for the curl request

# Function to log messages
log_message() {
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $1" >> "$LOG_FILE"
    echo "[$timestamp] $1"
}

# query
QUERY=' make the query here depend on your api'

log_message "Starting API health check for $API_URL"

# Send the POST request with the query and capture both status code and response body
HTTP_RESPONSE=$(curl --write-out "HTTPSTATUS:%{http_code}" --silent \
                    --max-time "$TIMEOUT" \
                    -X POST "$API_URL" \
                    -H "Content-Type: application/json" \
                    -d "$QUERY")

# Extract the status code and response body
HTTP_BODY=$(echo "$HTTP_RESPONSE" | sed -e 's/HTTPSTATUS\:.*//g')
HTTP_STATUS=$(echo "$HTTP_RESPONSE" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://g')

# Check if the curl command itself failed (e.g., timeout)
if [ -z "$HTTP_STATUS" ]; then
    log_message "ERROR: Failed to connect to API. Curl command failed."
    log_message "Restarting $SERVICE_NAME..."
    
    # Attempt to restart the service
    if sudo systemctl restart "$SERVICE_NAME"; then
        log_message "Service $SERVICE_NAME restarted successfully."
    else
        log_message "ERROR: Failed to restart $SERVICE_NAME. Exit code: $?"
    fi
    exit 1
fi

# Check if the response code is 200 (OK)
if [ "$HTTP_STATUS" -eq 200 ]; then
    log_message "API is working correctly. Response status: 200 OK"
else
    log_message "API returned non-200 status code: $HTTP_STATUS"
    log_message "Response body: $HTTP_BODY"
    log_message "Restarting $SERVICE_NAME..."
    
    # Attempt to restart the service
    if sudo systemctl restart "$SERVICE_NAME"; then
        log_message "Service $SERVICE_NAME restarted successfully."
    else
        log_message "ERROR: Failed to restart $SERVICE_NAME. Exit code: $?"
    fi
    
    # Verify the service is running after restart
    if sudo systemctl is-active --quiet "$SERVICE_NAME"; then
        log_message "Service $SERVICE_NAME is now running."
    else
        log_message "WARNING: Service $SERVICE_NAME is still not running after restart."
    fi
fi

exit 0
