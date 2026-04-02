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
apt install -y wget git

# clash-verge-rev 仓库
REPO_GIT="https://github.com/clash-verge-rev/clash-verge-rev.git" # 仓库地址
RELEASES=$(git ls-remote --tags --refs "$REPO_GIT" 2>/dev/null | sed 's/.*\///' | grep -E '^v[0-9]' | sort -Vr) # 获取所有版本

# 自动选择最新版本
SEL_VER=$(echo "$RELEASES" | head -n 1) # 选择最新版本
VER=$(echo "$SEL_VER" | tr -d 'v') # 去掉版本号前面的 'v'
DEB_FILE="Clash.Verge_${VER}_${MY_ARCH}.deb" # 官方标准文件名

# 下载 deb 文件
URL="https://github.com/clash-verge-rev/clash-verge-rev/releases/download/$SEL_VER/$DEB_FILE"
wget -O "$DEB_FILE" "$URL"

# 安装
apt install -y ./"$DEB_FILE"

echo -e "\033[36m======================\033[0m"
echo "✅ Clash Verge Rev $VER 安装成功！"
echo -e "\033[36m======================\033[0m"