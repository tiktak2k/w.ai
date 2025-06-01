#!/bin/bash

set -e

# Non-interactive setup
export DEBIAN_FRONTEND=noninteractive

# 1. Refresh package index
echo "Refreshing package index..."
sudo apt update -y

# 2. Remove existing NVIDIA drivers and CUDA
echo "Removing existing NVIDIA drivers and CUDA..."
dpkg -l | grep -i nvidia || true
sudo apt-get remove --purge '^nvidia-.*' -y || true
sudo apt remove --purge cuda -y || true
sudo apt autoremove -y || true

# 3. Update system packages
echo "Updating system packages..."
sudo apt update -y && sudo apt upgrade -y --fix-missing -o Dpkg::Options::="--force-confold"

# 4. Install general utilities and tools
echo "Installing utilities and tools..."
sudo apt install -y screen curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev --fix-missing -o Dpkg::Options::="--force-confold"

# 5. Install Python
echo "Installing Python..."
sudo apt install -y python3 python3-pip python3-venv python3-dev --fix-missing -o Dpkg::Options::="--force-confold"

# 6. Install NodeJS
echo "Installing NodeJS..."
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo bash -
sudo apt install -y nodejs --fix-missing -o Dpkg::Options::="--force-confold"
node -v
npm install -g yarn
yarn -v

# 7. Install NVIDIA driver
echo "Installing NVIDIA driver..."
sudo apt install -y nvidia-driver-570 --fix-missing -o Dpkg::Options::="--force-confold"

# 8. Install CUDA 12.9.0
echo "Installing CUDA..."
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin
sudo mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600

wget https://developer.download.nvidia.com/compute/cuda/12.9.0/local_installers/cuda-repo-ubuntu2204-12-9-local_12.9.0-575.51.03-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu2204-12-9-local_12.9.0-575.51.03-1_amd64.deb
sudo cp /var/cuda-repo-ubuntu2204-12-9-local/cuda-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update -y
sudo apt-get install -y cuda-toolkit-12-9 --fix-missing -o Dpkg::Options::="--force-confold"

# 9. Install W.AI
echo "Installing W.AI..."
curl -fsSL https://app.w.ai/install.sh | bash

# 10. Set environment variable
echo "Setting W.AI API Key..."
export W_AI_API_KEY=wsk-ZzGrmA6VIpZaigYKVGnNZTdML7s2-HwveB-ZHPLJ6cFEe9lCMd

# 11. Install PM2 globally
echo "Installing PM2..."
npm install -g pm2

# 12. Generate wai.config.js
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
# echo "Rebooting..."
# sudo reboot
