#!/usr/bin/env bash

# Установка AWS CLI на Linux (Redhat, Ubuntu)
if command -v yum &> /dev/null; then
    sudo yum install -y aws-cli
elif command -v apt-get &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y awscli
# Установка AWS CLI на MacOS
elif command -v brew &> /dev/null; then
    brew install aws-cli
# Установка AWS CLI на Windows (предполагается использование WSL)
elif command -v wsl &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y aws-cli
else
    echo "Unsupported OS"
    exit 1
fi

# Настройка AWS CLI профиля
aws configure --profile your_profile_name
