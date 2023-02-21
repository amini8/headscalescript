#!/bin/bash

# Define colors for logging
plain='\033[0m'
red='\033[0;31m'
blue='\033[1;34m'
green='\033[0;32m'
yellow='\033[0;33m'

# Set up variables for paths and file names
HOME_PATH='/etc/headscale'
DATA_PATH='/var/lib/headscale'
TEMP_PATH='/var/run/headscale'
BINARY_FILE_PATH='/usr/local/bin/headscale'
SERVICE_FILE_PATH='/etc/systemd/system/headscale.service'

# Function for logging errors
function LOGE() {
  echo -e "${red}[ERR] $* ${plain}"
}

# Function for logging information
function LOGI() {
  echo -e "${green}[INF] $* ${plain}"
}

# Function for logging debug messages
function LOGD() {
  echo -e "${yellow}[DEG] $* ${plain}"
}

# Function to download and install headscale
function install_headscale() {
  LOGD "Installing headscale..."
  
  # Install required packages
  apt-get update
  apt-get install -y curl wget
  
  # Download and install headscale binary
  curl -sL https://api.github.com/repos/juanfont/headscale/releases/latest \
  | grep "browser_download_url.*linux_amd64" \
  | cut -d : -f 2,3 \
  | tr -d \" \
  | wget -qi -
  
  chmod +x headscale_linux_amd64
  mv headscale_linux_amd64 $BINARY_FILE_PATH
  
  # Create required directories
  mkdir -p $HOME_PATH $DATA_PATH $TEMP_PATH
  
  # Create headscale service file
  cat >$SERVICE_FILE_PATH <<EOF
[Unit]
Description=headscale controller
After=syslog.target
After=network.target

[Service]
Type=simple
User=root
Group=root
ExecStart=$BINARY_FILE_PATH serve --config=$DATA_PATH/config.json
Restart=always

[Install]
WantedBy=multi-user.target
EOF
  
  # Enable and start headscale service
  systemctl daemon-reload
  systemctl enable headscale.service
  systemctl start headscale.service
  
  LOGI "headscale installed successfully!"
}

# Call the install_headscale function
install_headscale
