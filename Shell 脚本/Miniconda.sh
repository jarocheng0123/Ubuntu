#!/bin/bash

# 获取真实用户
CURRENT_USER="$SUDO_USER"
HOME_DIR=$(getent passwd "$CURRENT_USER" | cut -d: -f6)

# 自动检测架构
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    CONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    CONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh"
else
    echo "不支持的架构"
    exit 1
fi

# 安装依赖
apt update
apt install wget -y

# 安装路径
CONDA_PATH="$HOME_DIR/miniconda3"

# 下载并安装
if [ ! -d "$CONDA_PATH" ]; then
    wget "$CONDA_URL" -O miniconda.sh
    chmod +x miniconda.sh
    runuser -u "$CURRENT_USER" -- "$PWD/miniconda.sh" -b -p "$CONDA_PATH"
    rm -f miniconda.sh
fi

# 初始化 Conda
runuser -u "$CURRENT_USER" -- "$CONDA_PATH/bin/conda" init bash

# 自动接受服务条款
runuser -u "$CURRENT_USER" -- "$CONDA_PATH/bin/conda" tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
runuser -u "$CURRENT_USER" -- "$CONDA_PATH/bin/conda" tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

# 输出信息
echo "=============================================="
echo "Miniconda 安装完成！"
echo "路径：$CONDA_PATH"
echo "=============================================="
echo -e "\n请重启终端后使用 conda 命令！"
echo "=============================================="
echo "开启自动激活：conda config --set auto_activate_base true"
echo "关闭自动激活：conda config --set auto_activate_base false"
echo "创建环境：conda create -n py312 python=3.12 -y"
echo "删除环境：conda remove -n py312 --all -y"
echo "激活环境：conda activate py312"
echo "退出环境：conda deactivate"
echo "=============================================="