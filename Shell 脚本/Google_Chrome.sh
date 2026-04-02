#!/bin/bash
set -e

# 架构判断
ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then
    MY_ARCH="amd64"
elif [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
    MY_ARCH="arm64"
else
    echo "不支持的架构"
    exit 1
fi

# 安装依赖
apt update -y
apt install -y wget gpg

# 导入 Google 官方密钥
wget -qO - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg

# 添加 Google Chrome 官方源
echo "deb [arch=$MY_ARCH signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list

# 更新并安装 Chrome
apt update -y
apt install -y google-chrome-stable

echo -e "\033[36m======================\033[0m"
echo "✅ Google Chrome 安装成功！"
echo -e "\033[36m======================\033[0m"