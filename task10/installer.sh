#!/usr/bin/env bash

echo 'start'

# Установка AWS CLI на Linux (Redhat, Ubuntu)
if command -v yum &> /dev/null; then
    sudo yum install -y unzip
    # Download AWS CLI package
    curl "https://d1vvhvl2y92vvt.cloudfront.net/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    # Unzip the package
    unzip awscliv2.zip
    # Run the installation script
    sudo ./aws/install
    # Verify the installation
    aws --version
elif command -v apt-get &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y awscli
    aws --version
# Установка AWS CLI на MacOS
elif command -v brew &> /dev/null; then
    brew install aws-cli
    aws --version
# Установка AWS CLI на Windows (предполагается использование WSL)
elif command -v wsl &> /dev/null; then
    ./ts.bat
else
    echo "Unsupported OS"
    exit 1
fi
