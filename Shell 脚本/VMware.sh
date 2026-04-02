#!/bin/bash

echo -e "\033[33m建立VMware共享文件夹快捷方式\033[0m"
echo -e "\033[36m==========================\033[0m"

sudo apt update
sudo apt install -y open-vm-tools open-vm-tools-desktop 

# 创建目录
sudo mkdir -p /mnt/hgfs

# 启用并挂载
sudo vmhgfs-fuse .host:/ /mnt/hgfs -o allow_other

#当前用户主目录
USER_HOME="$(getent passwd "${SUDO_USER:-$(whoami)}" | awk -F: '{print $6}')"

#当前用户桌面
if [[ "$LANG" == zh_CN.UTF-8 || "$LANG" == zh_CN || "$LANG" == zh* ]]; then
    USER_DESKTOP="${USER_HOME}/桌面"
else
    USER_DESKTOP="${USER_HOME}/Desktop"
fi

# 桌面路径变量
SHORTCUT_FILE="$USER_DESKTOP/VMware.desktop"

# 创建 VMware.desktop 文件
cat << EOF > "$SHORTCUT_FILE"
[Desktop Entry]
Name=VMware
Exec=xdg-open /mnt/hgfs
Terminal=false
Type=Application
Icon=/usr/share/pixmaps/evolution-data-server/category_gifts_16.png
EOF

# 赋予执行权限
chmod +x "$SHORTCUT_FILE"

# 自启动VM共享文件夹
FSTAB_FILE="/etc/fstab"
if ! grep -q ".host:/ /mnt/hgfs fuse.vmhgfs-fuse allow_other,auto 0 0" "$FSTAB_FILE"; then
    echo ".host:/ /mnt/hgfs fuse.vmhgfs-fuse allow_other,auto 0 0" | sudo tee -a "$FSTAB_FILE" > /dev/null
fi

echo -e "\033[36m======================\033[0m"
echo -e "\033[33mVMware共享文件执行完成！\033[0m"
echo -e "\033[36m======================\033[0m"