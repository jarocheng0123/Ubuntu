#!/bin/bash
set -e

# 基础配置
CURRENT_USER="$SUDO_USER" # 获取当前用户名

# 架构判断
ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then
    MY_ARCH="amd64"
elif [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
    MY_ARCH="arm64"
else
    exit 1
fi

# 安装依赖
apt update -y
apt install -y software-properties-common apt-transport-https wget gpg

# 安装 VS Code 官方源
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg # 下载密钥
install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/ # 安装密钥
rm -f microsoft.gpg # 删除密钥文件

# 添加源
sh -c "echo \"deb [arch=$MY_ARCH signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main\" > /etc/apt/sources.list.d/vscode.list"

# 安装 VS Code
apt update -y
apt install code -y

# 安装中文语言包
sudo -u "$CURRENT_USER" code --install-extension MS-CEINTL.vscode-language-pack-zh-hans

# 安装完成
echo -e "\033[36m======================\033[0m"
echo " ✅ VS Code 安装成功！"
echo -e "\033[36m======================\033[0m"