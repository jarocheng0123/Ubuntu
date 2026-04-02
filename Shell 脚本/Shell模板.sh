#!/bin/bash


# ===================== 日志记录 =====================
SCRIPT_NAME=$(basename "$0" .sh)
LOG_FILE="${SCRIPT_NAME}_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee >(sed -E "s/\\x1B\[[0-9;]*[a-zA-Z]//g" >> "$LOG_FILE")) 2>&1


# ===================== 颜色样式 =====================
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
BLUE="\033[34m"
RESET="\033[0m"

success() { echo -e "${GREEN}$1${RESET}"; } # 成功信息
warning() { echo -e "${YELLOW}$1${RESET}"; } # 警告信息
danger() { echo -e "${RED}$1${RESET}"; exit 1; } # 错误信息


# ===================== 权限校验 =====================
if [ -z "$SUDO_USER" ]; then
    danger "❌ 请使用 sudo 运行此脚本！"
    exit 1
fi

CURRENT_USER="$SUDO_USER"
HOME_DIR=$(getent passwd "$CURRENT_USER" | cut -d: -f6) # 获取用户主目录


# ===================== 输入法 =====================
if pgrep -x fcitx >/dev/null 2>&1; then
    FCITX_STATUS=$(success "已运行")
else
    FCITX_STATUS=$(warning "未运行")
fi


# ===================== 系统信息 =====================
hostname=$(hostname) # 获取主机名
ARCH=$(uname -m) # 获取系统架构
KERNEL=$(uname -r) # 获取内核版本
OS_VERSION=$(lsb_release -d | cut -f2 2>/dev/null) # 获取系统版本
OS_DISTRO=$(grep ^NAME /etc/os-release | cut -d'"' -f2) # 获取发行版
VIRTUAL=$(systemd-detect-virt 2>/dev/null || echo "none") # 获取虚拟化类型

if [[ "$ARCH" == "x86_64" ]]; then
    MY_ARCH="linux_x86_64"
elif [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
    MY_ARCH="linux_aarch64"
else
    MY_ARCH="未知架构"
fi


# ===================== 硬件信息 =====================
CPU_MODEL=$(grep "model name" /proc/cpuinfo | head -n1 | cut -d: -f2 | xargs) # 获取CPU型号
CPU_THREADS=$(grep -c "^processor" /proc/cpuinfo) # 获取CPU线程数
MEM_TOTAL=$(free -h | awk '/^Mem/{print $2}') # 获取总内存

DISK_TOTAL=$(df -h / | awk 'NR==2{print $2}') # 获取磁盘总容量
DISK_USED=$(df -h / | awk 'NR==2{print $3}') # 获取磁盘已使用
DISK_FREE=$(df -h / | awk 'NR==2{print $4}') # 获取磁盘剩余
DISK_USAGE=$(df -h / | awk 'NR==2{print $5}') # 获取磁盘使用率


# ===================== 网络信息 =====================
# 公网IP
PUBLIC_IP=$(curl -s --connect-timeout 2 ifconfig.me 2>/dev/null)
[ -z "$PUBLIC_IP" ] && PUBLIC_IP="获取失败"

# 内网IP
LOCAL_IP=$(hostname -I | awk '{print $1}')

# 网卡名称
INTERFACE=$(ip -br route get 1.1.1.1 2>/dev/null | awk '{print $5}')
[ -z "$INTERFACE" ] && INTERFACE=$(ip -br link | awk '/UP/ && !/LOOPBACK/ {print $1}' | head -1)
[ -z "$INTERFACE" ] && INTERFACE="未知"

# 子网掩码
PREFIX_LEN=$(ip a show "$INTERFACE" 2>/dev/null | awk '/inet /{print $2}' | cut -d'/' -f2)
case "$PREFIX_LEN" in
    8) NETMASK="255.0.0.0" ;;
    16) NETMASK="255.255.0.0" ;;
    24) NETMASK="255.255.255.0" ;;
    25) NETMASK="255.255.255.128" ;;
    26) NETMASK="255.255.255.192" ;;
    27) NETMASK="255.255.255.224" ;;
    28) NETMASK="255.255.255.240" ;;
    29) NETMASK="255.255.255.248" ;;
    30) NETMASK="255.255.255.252" ;;
    *) NETMASK="$PREFIX_LEN" ;;
esac
[ -z "$NETMASK" ] && NETMASK="未获取"

# 网关
GATEWAY=$(ip route show default 2>/dev/null | awk '/default via/ {print $3}')
[ -z "$GATEWAY" ] && GATEWAY="未获取"

# DNS
DNS=$(resolvectl status 2>/dev/null | grep "DNS Servers" | head -1 | awk '{print $3}')
[ -z "$DNS" ] && DNS=$(grep -m1 nameserver /etc/resolv.conf 2>/dev/null | awk '{print $2}')
[ -z "$DNS" ] && DNS="未获取"

# WiFi名称
WIFI_SSID="有线网络"
if command -v iwgetid >/dev/null 2>&1; then
    WIFI_SSID=$(iwgetid -r 2>/dev/null)
fi
[ -z "$WIFI_SSID" ] && WIFI_SSID="未连接WiFi"

# MAC地址
MAC_ADDR=$(cat /sys/class/net/"$INTERFACE"/address 2>/dev/null)
[ -z "$MAC_ADDR" ] && MAC_ADDR="未获取"


# ===================== 网络检测 =====================
check_site() {
    local site="$1"
    local t

    t=$(ping -c 1 -W 1 "$site" 2>/dev/null | awk '/time=/ {
        for(i=1;i<=NF;i++) if ($i ~ /^time=/) {
            sub(/^time=/,"",$i); sub(/ms$/,"",$i); printf "%.0fms", $i
            exit
        }
    }')

    if [ -n "$t" ]; then
        echo "success $t"
    else
        echo "danger"
    fi
}

# 常用网站
PING_BAIDU=$(check_site "baidu.com")
PING_BILIBILI=$(check_site "bilibili.com")
PING_GITHUB=$(check_site "github.com")
PING_GOOGLE=$(check_site "google.com")
PING_YOUTUBE=$(check_site "youtube.com")

# 国内镜像源
PING_ALIYUN=$(check_site "mirrors.aliyun.com")
PING_TSINGHUA=$(check_site "mirrors.tuna.tsinghua.edu.cn")
PING_USTC=$(check_site "mirrors.ustc.edu.cn")
PING_163=$(check_site "mirrors.163.com")
PING_HUAWEI=$(check_site "mirrors.huaweicloud.com")


# ===================== 软件检测 =====================
check_cmd() {
    if command -v "$1" >/dev/null 2>&1; then
        success "已安装"
    else
        warning "未安装"
    fi
}

check_deb() {
    if dpkg -l | grep -q "$1" 2>/dev/null; then
        success "已安装"
    else
        warning "未安装"
    fi
}


# ===================== 工具检测 =====================
# 虚拟机增强工具
CMD_VM_TOOLS=$(check_cmd vmtoolsd)
CMD_VM_DESKTOP=$(check_deb open-vm-tools-desktop)

# 网络下载工具
CMD_CURL=$(check_cmd curl)
CMD_WGET=$(check_cmd wget)

# 开发与文件工具
CMD_GIT=$(check_cmd git)
CMD_UNZIP=$(check_cmd unzip)
CMD_TREE=$(check_cmd tree)

# 文本编辑工具
CMD_NANO=$(check_cmd nano)
CMD_VIM=$(check_cmd vim)

# 网络管理工具
CMD_NET_TOOLS=$(check_cmd ifconfig)

# 图像编辑工具
CMD_GIMP=$(check_cmd gimp)

# 摄像头相关工具
CMD_CHEESE=$(check_cmd cheese)
CMD_V4L2=$(check_cmd v4l2-ctl)

# 常用应用程序
CMD_VS_CODE=$(check_cmd code)
CMD_CLASH_VERGE=$(check_cmd clash-verge-rev)


# ===================== 系统环境 =====================
# Python
if command -v python3 >/dev/null 2>&1; then
    PY_VERSION=$(success "$(python3 -V 2>/dev/null | awk '{print $2}')")
else
    PY_VERSION=$(warning "未安装")
fi

# Conda
if command -v conda >/dev/null 2>&1; then
    CMD_CONDA=$(success "已安装")
else
    CMD_CONDA=$(warning "未安装")
fi

MINICONDA_PATH="未找到"
[ -d "$HOME/miniconda3" ] && MINICONDA_PATH="已找到"
[ -d "/opt/miniconda3" ] && MINICONDA_PATH="已找到"

if [ "$MINICONDA_PATH" = "已找到" ]; then
    MINICONDA_PATH=$(success "$MINICONDA_PATH")
else
    MINICONDA_PATH=$(warning "$MINICONDA_PATH")
fi

# ROS
ROS_DISTRO=$(printenv ROS_DISTRO 2>/dev/null)
if [ -n "$ROS_DISTRO" ]; then
    ROS_VERSION=$(success "$ROS_DISTRO")
else
    ROS_VERSION=$(warning "未安装")
fi


# ===================== 外部设备 =====================
if [ -n "$(ls /dev/video* 2>/dev/null)" ]; then
    CAMERA_STATUS=$(success "已检测")
else
    CAMERA_STATUS=$(warning "未检测")
fi

if lsblk -d -o tran | grep -q usb 2>/dev/null; then
    USB_STORAGE=$(success "已连接")
else
    USB_STORAGE=$(warning "未连接")
fi


# =============================================================================================
# ========================================== 输出界面 ==========================================
clear # 清除终端


echo -e "==============================================================="
echo -e "📋 系统检测报告 | $(date '+%Y-%m-%d %H:%M:%S') | $(uptime -p | sed -e 's/up //;s/days/天/;s/hours/小时/;s/minutes/分钟/;s/day/天/;s/hour/小时/')"
echo -e "==============================================================="


echo -e "\n${BLUE}===================== 终端信息 =====================${RESET}"
echo -e "🗣️ 系统语言：      ${GREEN}${LANG}${RESET}"
echo -e "⌨️ FCITX 状态：    $FCITX_STATUS"
echo -e "⌨️ 当前输入法：    ${GREEN}${FCITX_IM:-未配置}${RESET}"


echo -e "\n${BLUE}===================== 运行环境 =====================${RESET}"
if [ "$VIRTUAL" = "none" ]; then
    echo -e "☁️ 运行环境：       ${GREEN}物理机${RESET}"
else
    echo -e "☁️ 运行环境：       ${YELLOW}虚拟机 ($VIRTUAL)${RESET}"
fi


echo -e "\n${BLUE}===================== 硬件信息 =====================${RESET}"
echo -e "🔍 CPU 型号：       ${GREEN}$CPU_MODEL${RESET}"
echo -e "🧵 CPU 线程：       ${GREEN}$CPU_THREADS${RESET}"
echo -e "🧠 总内存：         ${GREEN}$MEM_TOTAL${RESET}"
echo -e "💽 磁盘总容量：     ${GREEN}$DISK_TOTAL${RESET}"
echo -e "💽 磁盘已使用：     ${GREEN}$DISK_USED${RESET}"
echo -e "💽 磁盘剩余：       ${GREEN}$DISK_FREE${RESET}"
echo -e "💽 磁盘使用率：     ${GREEN}$DISK_USAGE${RESET}"


echo -e "\n${BLUE}===================== 系统信息 =====================${RESET}"
echo -e "💻 系统架构：       ${GREEN}$MY_ARCH${RESET}"
echo -e "🐧 系统发行版：     ${GREEN}$OS_DISTRO${RESET}"
echo -e "📌 系统版本：       ${GREEN}$OS_VERSION${RESET}"
echo -e "🧩 内核版本：       ${GREEN}$KERNEL${RESET}"


echo -e "\n${BLUE}===================== 用户权限 =====================${RESET}"
getent passwd | awk -F: '$3>=1000 && $3!=65534 {print $1,$3,$6}' | while read user uid home; do
    if id -nG "$user" | grep -qw "sudo"; then
        role="管理员   🟢"
    else
        role="普通用户 🔵"
    fi
    shell=$(basename "$(getent passwd "$user" | cut -d: -f7)")
    perm=$(stat -c "%A" "$home" 2>/dev/null)
    printf "${GREEN}%-12s${RESET} UID:%-6s ${YELLOW}%-12s${RESET} Shell:%-10s 权限: %s\n" "$user" "$uid" "$role" "$shell" "$perm"
done


echo -e "\n${BLUE}===================== 用户信息 =====================${RESET}"
echo -e "🏠 主机名：         ${GREEN}$hostname${RESET}"
echo -e "👤 当前用户：       ${GREEN}$CURRENT_USER${RESET}"
echo -e "📂 用户目录：       ${GREEN}$HOME_DIR${RESET}"


echo -e "\n${BLUE}===================== 网络状态 =====================${RESET}"
if [ "$PUBLIC_IP" = "获取失败" ]; then
    echo -e "🌍 公网IP：         ${YELLOW}获取失败${RESET}"
else
    echo -e "🌍 公网IP：         ${GREEN}$PUBLIC_IP${RESET}"
fi

echo -e "🌐 内网IP：         ${GREEN}$LOCAL_IP${RESET}"
echo -e "🚪 网关地址：       ${GREEN}$GATEWAY${RESET}"
echo -e "🔏 子网掩码：       ${GREEN}$NETMASK${RESET}"
echo -e "📡 DNS 服务器：     ${GREEN}$DNS${RESET}"
echo -e "🔌 物理网卡：       ${GREEN}$INTERFACE${RESET}"
echo -e "🏷️  MAC 地址：       ${GREEN}$MAC_ADDR${RESET}"
echo -e "📶 WiFi 名称：      ${GREEN}$WIFI_SSID${RESET}"

render_net() {
    local label="$1"
    local res="$2"
    local stat=$(echo "$res" | awk '{print $1}')
    local ms=$(echo "$res" | awk '{print $2}')

    if [ "$stat" = "success" ]; then
        printf "📡 %-10s ${GREEN}正常 %6s${RESET}\n" "$label" "$ms"
    else
        printf "📡 %-10s ${RED}异常${RESET}\n" "$label"
    fi
}


echo -e "\n${BLUE}===================== 网络连接测试 =====================${RESET}"
render_net "百度      "   "$PING_BAIDU"
render_net "哔哩哔哩  "   "$PING_BILIBILI"
render_net "GitHub "     "$PING_GITHUB"
render_net "Google "     "$PING_GOOGLE"
render_net "YouTube"     "$PING_YOUTUBE"


echo -e "\n${BLUE}===================== 国内镜像源检测 =====================${RESET}"
render_net "阿里云    "    "$PING_ALIYUN"
render_net "清华大学  "    "$PING_TSINGHUA"
render_net "中科大    "    "$PING_USTC"
render_net "网易      "    "$PING_163"
render_net "华为云    "    "$PING_HUAWEI"


echo -e "\n${BLUE}===================== 软件环境 =====================${RESET}"
echo -e "🧰 VM-Tools：        $CMD_VM_TOOLS"
echo -e "🖥️  VM-Desktop：      $CMD_VM_DESKTOP"
echo
echo -e "🔗 curl：            $CMD_CURL"
echo -e "🔗 wget：            $CMD_WGET"
echo
echo -e "🔧 git：             $CMD_GIT"
echo -e "🗂  unzip：           $CMD_UNZIP"
echo -e "🌳 tree：            $CMD_TREE"
echo
echo -e "📝 nano：            $CMD_NANO"
echo -e "📝 vim：             $CMD_VIM"
echo
echo -e "🌐 net-tools：       $CMD_NET_TOOLS"
echo
echo -e "🎨 gimp：            $CMD_GIMP"
echo
echo -e "🐍 Python3：         $PY_VERSION"
echo -e "🐍 Miniconda3：      $CMD_CONDA ($MINICONDA_PATH)"
echo -e "🤖 ROS：             $ROS_VERSION"
echo
echo -e "📷 cheese：          $CMD_CHEESE"
echo -e "🎥 v4l-utils：       $CMD_V4L2"
echo
echo -e "🐳 VS Code：         $CMD_VS_CODE"
echo -e "😺 Clash Verge：     $CMD_CLASH_VERGE"


echo -e "\n${BLUE}===================== 外部设备 =====================${RESET}"
echo -e "📷 摄像头：          $CAMERA_STATUS"
echo -e "💾 USB设备：         $USB_STORAGE"


echo -e "\n${BLUE}===================== 脚本目录文件 =====================${RESET}"
SCRIPT_PATH=$(realpath "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
echo -e "📄 脚本路径：${GREEN}$SCRIPT_PATH${RESET}"
echo -e "📂 当前目录：${GREEN}$SCRIPT_DIR${RESET}"
echo -e "📋 目录文件（权限 | 名称）："

ls -la "$SCRIPT_DIR" | awk '
NR>2 {
    perm = $1;
    name = $NF;
    # 只显示 .sh 和 .log 文件，排除所有隐藏文件和系统目录
    if (name ~ /\.(sh|log)$/ && name !~ /^\./) {
        printf "   ─ %-12s %s \n", perm, name;
    }
}'


# 运行结束
echo -e "\n${BLUE}===============================================================${RESET}"
echo -e "✅ 日志已保存至：${GREEN}$LOG_FILE${RESET}"
echo -e "\n=============================================================================="