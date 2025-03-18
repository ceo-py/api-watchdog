
# API Health Check Script

A robust bash script for monitoring API health and automatically restarting services when failures are detected.

## Overview

This utility monitors the health of an API endpoint by sending periodic requests and checking for proper responses. If the API fails to respond or returns an error status code, the script automatically restarts the associated service and logs the event.

## Features

- Periodic API health monitoring
- Automatic service restart on failure
- Comprehensive logging
- Configurable timeout and check frequency
- Systemd integration for scheduling

## Prerequisites

- Linux system with `systemd`
- `curl` command-line tool
- `sudo` privileges for service restart

## Installation

1. Clone this repository or download the script:

```bash
git clone https://github.com/ceo-py/api-watchdog.git
cd api-watchdog
```

2. Make the script executable:

```bash
chmod +x api-watchdog.sh
```

3. Configure the script parameters (see Configuration section below)

## Configuration

Edit the script to set the following parameters:

```bash
# Configuration
API_URL="https://your-api-endpoint.com/graphql"  # URL of your API
SERVICE_NAME="your-service-name"                 # Service name to restart (systemd service)
LOG_FILE="/var/log/api-watchdog.log"         # Log file location
TIMEOUT=10                                       # Timeout in seconds for the curl request
```

Also, modify the query to match your API's requirements:

```bash
# Query - modify this based on your API's expected format
QUERY='{"query": "{ status }"}'
```

## Setting Up as a Systemd Service

1. Create a service file for the health check script:

```bash
sudo nano /etc/systemd/system/api-watchdog.service
```

Add the following content:

```
[Unit]
Description=API Health Check Service
After=network.target

[Service]
Type=oneshot
ExecStart=/path/to/api-watchdog.sh
User=your-username

[Install]
WantedBy=multi-user.target
```

2. Create a timer file to run the script periodically:

```bash
sudo nano /etc/systemd/system/api-watchdog.timer
```

Add the following content:

```
[Unit]
Description=Run API Health Check every 5 minutes
Requires=api-watchdog.service

[Timer]
Unit=api-watchdog.service
OnBootSec=1min
OnUnitActiveSec=5min
AccuracySec=1s

[Install]
WantedBy=timers.target
```

3. Enable and start the timer:

```bash
sudo systemctl daemon-reload
sudo systemctl enable api-watchdog.timer
sudo systemctl start api-watchdog.timer
```

## Checking Status

To check if the timer is running:

```bash
sudo systemctl status api-watchdog.timer
```

To see the last execution logs:

```bash
sudo journalctl -u api-watchdog.service
```

To view the health check logs:

```bash
tail -f /var/log/api-watchdog.log
```

## Customization

### Changing Check Frequency

Edit the timer file and modify the `OnUnitActiveSec` value:

```
OnUnitActiveSec=10min  # Change to your desired interval
```

### Advanced Response Validation

For more complex APIs, you might want to modify the script to check for specific content in the response body, not just the HTTP status code.

## Troubleshooting

- **Script not running**: Check if the timer is active with `systemctl status api-watchdog.timer`
- **Service not restarting**: Verify sudo permissions for the user running the script
- **Curl errors**: Check network connectivity to the API endpoint

## License

[MIT License](LICENSE)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
