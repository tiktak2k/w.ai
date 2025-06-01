#!/bin/bash

set -e

# 1. Remove existing NVIDIA drivers and CUDA
echo "Removing existing NVIDIA drivers and CUDA..."
dpkg -l | grep -i nvidia
sudo apt-get remove --purge '^nvidia-.*' -y
sudo apt remove --purge cuda -y
sudo apt autoremove -y

# 2. Update system packages
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# 3. Install general utilities and tools
echo "Installing utilities and tools..."
sudo apt install screen curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev -y

# 4. Install Python
echo "Installing Python..."
sudo apt install python3 python3-pip python3-venv python3-dev -y

# 5. Install NodeJS
echo "Installing NodeJS..."
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo bash -
sudo apt install -y nodejs
node -v
npm install -g yarn
yarn -v

# 6. Install NVIDIA driver
echo "Installing NVIDIA driver..."
sudo apt install -y nvidia-driver-570

# 7. Install CUDA 12.9.0
echo "Installing CUDA..."
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin
sudo mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600

wget https://developer.download.nvidia.com/compute/cuda/12.9.0/local_installers/cuda-repo-ubuntu2204-12-9-local_12.9.0-575.51.03-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu2204-12-9-local_12.9.0-575.51.03-1_amd64.deb
sudo cp /var/cuda-repo-ubuntu2204-12-9-local/cuda-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt-get -y install cuda-toolkit-12-9

# 8. Install W.AI
echo "Installing W.AI..."
curl -fsSL https://app.w.ai/install.sh | bash

# 9. Set environment variable
echo "Setting W.AI API Key..."
export W_AI_API_KEY=wsk-ZzGrmA6VIpZaigYKVGnNZTdML7s2-HwveB-ZHPLJ6cFEe9lCMd

# 10. Install PM2 globally
echo "Installing PM2..."
npm install -g pm2

# 11. Generate wai.config.js
echo "Creating wai.config.js..."
cat <<EOL > wai.config.js
module.exports = {
  apps : [{
    name: 'wai-node',
    script: 'wai',
    args: 'run',
    instances: 50,
    autorestart: true,
    watch: false,
    env: {
      NODE_ENV: 'production',
      W_AI_API_KEY: 'wsk-ZzGrmA6VIpZaigYKVGnNZTdML7s2-HwveB-ZHPLJ6cFEe9lCMd'
    }
  }]
};
EOL

echo "Setup complete! 🎉"
echo "Please reboot the system manually to finalize NVIDIA driver and CUDA installation."
# Uncomment below if you want to force a reboot automatically:
echo "Rebooting..."
sudo reboot
