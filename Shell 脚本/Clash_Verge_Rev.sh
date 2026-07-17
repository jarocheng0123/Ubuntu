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

# Ubuntu 22.04 专用依赖
if [[ "${VERSION_ID:-}" == "22.04" ]]; then
    echo "检测到 Ubuntu 22.04，安装 Clash Verge Rev 所需依赖"
    apt install -y \
        libwebkit2gtk-4.0-dev libjavascriptcoregtk-4.0-dev \
        libwebkit2gtk-4.1-0 libjavascriptcoregtk-4.1-0 libsoup-3.0-0 \
        libgtk-3-0 libayatana-appindicator3-1 libfuse2
fi

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

if [[ "${VERSION_ID:-}" == "22.04" ]]; then
    # Ubuntu 22.04：按指定流程安装并修复依赖
    dpkg -i "./$DEB_FILE" || true
    apt --fix-broken install -y
    dpkg --configure clash-verge
else
    # Ubuntu 24.04 等版本直接由 apt 处理本地 DEB 依赖
    apt install -y "./$DEB_FILE"
fi

# 安装
apt install -y ./"$DEB_FILE"

# 清理下载的 deb 安装包
rm -f -- "$DEB_FILE"

echo -e "\033[36m======================\033[0m"
echo "✅ Clash Verge Rev $VER 安装成功！"
echo -e "\033[36m======================\033[0m"