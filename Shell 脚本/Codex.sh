#!/usr/bin/env bash
set -Eeuo pipefail

# OpenAI Codex CLI unattended installer for Ubuntu/Debian.
# Run with: sudo /home/ubunut24/codex.sh

if [[ -t 1 && "${NO_COLOR:-}" == "" ]]; then
    C_CYAN='\033[36m'
    C_GREEN='\033[32m'
    C_YELLOW='\033[33m'
    C_RED='\033[31m'
    C_RESET='\033[0m'
else
    C_CYAN=''
    C_GREEN=''
    C_YELLOW=''
    C_RED=''
    C_RESET=''
fi

info()    { printf '%b%s%b\n' "$C_CYAN" "$*" "$C_RESET"; }
success() { printf '%b%s%b\n' "$C_GREEN" "$*" "$C_RESET"; }
warning() { printf '%b%s%b\n' "$C_YELLOW" "$*" "$C_RESET"; }
danger()  { printf '%b%s%b\n' "$C_RED" "$*" "$C_RESET" >&2; }

die() {
    danger "❌ $*"
    exit 1
}

# ===================== 权限校验 =====================
[[ "$(id -u)" -eq 0 ]] || die "请使用 sudo 运行此脚本！"
[[ -n "${SUDO_USER:-}" ]] || die "无法取得 SUDO_USER，请从普通用户账户使用 sudo 运行。"
[[ "$SUDO_USER" != "root" ]] || die "SUDO_USER 是 root，请从普通用户账户使用 sudo 运行。"

CURRENT_USER="$SUDO_USER"

command -v getent >/dev/null 2>&1 || die "系统缺少 getent，无法安全解析用户信息。"
PASSWD_ENTRY="$(getent passwd "$CURRENT_USER" || true)"
[[ -n "$PASSWD_ENTRY" ]] || die "找不到用户：$CURRENT_USER"

IFS=: read -r _ _ CURRENT_UID CURRENT_GID _ HOME_DIR USER_SHELL <<< "$PASSWD_ENTRY"
[[ "$CURRENT_UID" =~ ^[0-9]+$ ]] || die "用户 UID 无效。"
[[ "$CURRENT_GID" =~ ^[0-9]+$ ]] || die "用户 GID 无效。"
[[ -n "$HOME_DIR" && "$HOME_DIR" == /* && -d "$HOME_DIR" ]] || die "用户主目录无效：$HOME_DIR"

CURRENT_GROUP="$(id -gn "$CURRENT_USER")"

# ===================== 系统校验 =====================
[[ -r /etc/os-release ]] || die "无法识别当前 Linux 发行版。"
# shellcheck disable=SC1091
. /etc/os-release

case "${ID:-}:${ID_LIKE:-}" in
    ubuntu:*|debian:*|*:ubuntu*|*:debian*) ;;
    *) die "此脚本仅支持 Ubuntu/Debian；当前系统：${PRETTY_NAME:-unknown}" ;;
esac

case "$(uname -m)" in
    x86_64|aarch64|arm64) ;;
    *) die "当前 CPU 架构可能不受 Codex 支持：$(uname -m)" ;;
esac

info "========================================"
info "安装用户：$CURRENT_USER"
info "主目录：  $HOME_DIR"
info "系统：    ${PRETTY_NAME:-unknown}"
info "架构：    $(uname -m)"
info "========================================"

# ===================== 系统依赖 =====================
export DEBIAN_FRONTEND=noninteractive

info "正在更新软件包索引……"
apt-get -o Acquire::Retries=3 update

info "正在安装基础依赖……"
apt-get -o Acquire::Retries=3 install -y \
    bubblewrap \
    ca-certificates \
    curl \
    git \
    sudo

# ===================== 官方无人值守安装 =====================
INSTALL_URL="https://chatgpt.com/codex/install.sh"
INSTALL_TMP="$(mktemp /tmp/codex-install.XXXXXX)"

cleanup() {
    rm -f -- "$INSTALL_TMP"
}
trap cleanup EXIT

info "正在下载 OpenAI 官方 Codex 安装器……"
curl \
    --fail \
    --silent \
    --show-error \
    --location \
    --connect-timeout 15 \
    --max-time 300 \
    --retry 4 \
    --retry-delay 2 \
    --retry-all-errors \
    --proto '=https' \
    --tlsv1.2 \
    --output "$INSTALL_TMP" \
    "$INSTALL_URL"

chmod 0755 "$INSTALL_TMP"
chown "$CURRENT_UID:$CURRENT_GID" "$INSTALL_TMP"

info "正在以用户 $CURRENT_USER 的身份安装 Codex CLI……"
# env -i 防止 root 的代理、HOME、语言工具缓存等环境变量透传给目标用户。
sudo -H -u "$CURRENT_USER" env -i \
    HOME="$HOME_DIR" \
    USER="$CURRENT_USER" \
    LOGNAME="$CURRENT_USER" \
    SHELL="$USER_SHELL" \
    PATH="/usr/local/bin:/usr/bin:/bin" \
    LANG="${LANG:-C.UTF-8}" \
    CODEX_NON_INTERACTIVE=1 \
    sh "$INSTALL_TMP"

rm -f -- "$INSTALL_TMP"
trap - EXIT

# ===================== 定位 Codex =====================
CODEX_BIN="$HOME_DIR/.local/bin/codex"
if [[ ! -x "$CODEX_BIN" ]]; then
    CODEX_BIN="$(
        sudo -H -u "$CURRENT_USER" env -i \
            HOME="$HOME_DIR" \
            PATH="$HOME_DIR/.local/bin:/usr/local/bin:/usr/bin:/bin" \
            sh -c 'command -v codex 2>/dev/null || true'
    )"
fi

[[ -n "$CODEX_BIN" && "$CODEX_BIN" == /* && -x "$CODEX_BIN" ]] || \
    die "官方安装器已结束，但没有找到可执行的 codex 命令。"

# 提供系统级命令入口，使普通用户和 sudo -H codex 都能找到同一程序。
GLOBAL_CODEX="/usr/local/bin/codex"
if [[ -e "$GLOBAL_CODEX" || -L "$GLOBAL_CODEX" ]]; then
    EXISTING_TARGET="$(readlink -f "$GLOBAL_CODEX" 2>/dev/null || true)"
    REQUESTED_TARGET="$(readlink -f "$CODEX_BIN")"
    if [[ "$EXISTING_TARGET" != "$REQUESTED_TARGET" ]]; then
        warning "⚠️ $GLOBAL_CODEX 已存在且指向其他程序，未覆盖。"
        warning "   root 启动时请使用：sudo -H $CODEX_BIN"
    fi
else
    ln -s "$CODEX_BIN" "$GLOBAL_CODEX"
fi

# ===================== PATH 配置 =====================
PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'

ensure_user_path() {
    local rc_file="$1"
    local rc_dir
    rc_dir="$(dirname "$rc_file")"
    [[ "$rc_dir" == "$HOME_DIR" ]] || die "拒绝写入用户主目录之外的启动文件：$rc_file"

    if [[ -L "$rc_file" ]]; then
        warning "⚠️ 跳过符号链接启动文件：$rc_file"
        return
    fi

    if [[ -f "$rc_file" ]] && \
       grep -Eq '^[[:space:]]*export[[:space:]]+PATH="?\$HOME/\.local/bin:\$PATH"?[[:space:]]*$' "$rc_file"; then
        return
    fi

    sudo -H -u "$CURRENT_USER" env -i \
        HOME="$HOME_DIR" \
        PATH="/usr/bin:/bin" \
        sh -c 'printf "\n# Codex CLI\n%s\n" "$1" >> "$2"' sh "$PATH_LINE" "$rc_file"
}

ensure_user_path "$HOME_DIR/.profile"
case "$USER_SHELL" in
    */bash) ensure_user_path "$HOME_DIR/.bashrc" ;;
    */zsh)  ensure_user_path "$HOME_DIR/.zshrc" ;;
esac

# ===================== 完全访问配置 =====================
write_full_access_config() {
    local config_home="$1"
    local owner_uid="$2"
    local owner_gid="$3"
    local config_dir="$config_home/.codex"
    local config_path="$config_dir/config.toml"
    local temp_config

    [[ "$config_home" == /* ]] || die "配置主目录不是绝对路径：$config_home"
    if [[ -L "$config_dir" ]]; then
        die "拒绝写入符号链接配置目录：$config_dir"
    fi

    install -d -m 0700 -o "$owner_uid" -g "$owner_gid" "$config_dir"
    temp_config="$(mktemp "$config_dir/config.toml.tmp.XXXXXX")"

    # HERE-DOC 内容必须顶格，避免无意义缩进；TOML 本身允许前导空格。
    cat > "$temp_config" <<'EOF'
# Codex 完全访问模式
# 无需审批；禁用 Codex 沙箱边界；允许网络及当前系统用户权限覆盖的文件访问。
approval_policy = "never"
sandbox_mode = "danger-full-access"
EOF

    # 这两个键是顶层配置键。清除旧定义以保证脚本可重复执行且不产生重复键。
    if [[ -f "$config_path" ]]; then
        awk '
            !/^[[:space:]]*approval_policy[[:space:]]*=/ &&
            !/^[[:space:]]*sandbox_mode[[:space:]]*=/
        ' "$config_path" >> "$temp_config"
    fi

    chown "$owner_uid:$owner_gid" "$temp_config"
    chmod 0600 "$temp_config"
    mv -f -- "$temp_config" "$config_path"
    chown "$owner_uid:$owner_gid" "$config_path"
    chmod 0600 "$config_path"

    # 允许 TOML 合法空白及行尾注释，避免精确整行匹配造成误报。
    grep -Eq '^[[:space:]]*approval_policy[[:space:]]*=[[:space:]]*"never"([[:space:]]*#.*)?[[:space:]]*$' "$config_path" || \
        die "approval_policy 写入校验失败：$config_path"
    grep -Eq '^[[:space:]]*sandbox_mode[[:space:]]*=[[:space:]]*"danger-full-access"([[:space:]]*#.*)?[[:space:]]*$' "$config_path" || \
        die "sandbox_mode 写入校验失败：$config_path"
}

# 普通用户运行 codex 时使用。
write_full_access_config "$HOME_DIR" "$CURRENT_UID" "$CURRENT_GID"
# sudo -H codex 时使用，给予真正的 root 系统权限。
write_full_access_config "/root" "0" "0"

# ===================== 验证与完成提示 =====================
info "=== Codex 版本 ==="
sudo -H -u "$CURRENT_USER" env -i \
    HOME="$HOME_DIR" \
    PATH="$HOME_DIR/.local/bin:/usr/local/bin:/usr/bin:/bin" \
    "$CODEX_BIN" --version

printf '\n'
success "========================================"
success "✅ OpenAI Codex CLI 安装及完全访问配置完成"
success "========================================"
printf '安装用户：%s\n' "$CURRENT_USER"
printf 'Codex 程序：%s\n' "$CODEX_BIN"
printf '用户配置：%s/.codex/config.toml\n' "$HOME_DIR"
printf 'root 配置：/root/.codex/config.toml\n'

printf '\n'
warning "⚠️ 已设置 approval_policy = \"never\""
warning "⚠️ 已设置 sandbox_mode = \"danger-full-access\""
warning "普通运行 codex：拥有当前用户可访问范围内的完全权限。"
warning "运行 sudo -H codex：拥有无需 Codex 确认的 root 系统完全权限，风险极高。"

printf '\n普通用户启动：\n  codex\n'
printf '\nroot 完全权限启动：\n  sudo -H codex\n'
printf '\nChatGPT：\n  https://chatgpt.com/\n'
printf '\nCodex 用量统计：\n  https://chatgpt.com/codex/cloud/settings/analytics#usage\n'
printf '\n'
