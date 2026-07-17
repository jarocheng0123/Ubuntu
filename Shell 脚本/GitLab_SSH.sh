#!/usr/bin/env bash
set -Eeuo pipefail

danger() {
  printf '\033[1;31m%s\033[0m\n' "$*" >&2
}

# ===================== 权限校验 =====================
if [[ -z "${SUDO_USER:-}" || "$SUDO_USER" == "root" ]]; then
  danger "❌ 请使用 sudo 运行此脚本！"
  exit 1
fi

CURRENT_USER="$SUDO_USER"
CURRENT_GROUP="$(id -gn "$CURRENT_USER")"
HOME_DIR="$(getent passwd "$CURRENT_USER" | cut -d: -f6)"
if [[ -z "$HOME_DIR" || ! -d "$HOME_DIR" ]]; then
  danger "❌ 无法获取用户 ${CURRENT_USER} 的主目录！"
  exit 1
fi

as_user() {
  sudo -u "$CURRENT_USER" env HOME="$HOME_DIR" "$@"
}

# ====================== 请填写以下内容 ======================
GIT_USER_NAME="vitai"                    # 填写 Git 提交记录中显示的用户名
GIT_USER_EMAIL="xc.luo@vit.ai"           # 填写 GitLab 账号绑定的邮箱
GIT_SERVER_HOST="git.vitai.site"         # 填写 GitLab 服务器域名，不要带 https://
PROJECT_PATH="robotics-core-sdk/dm-finger-gripper" # 填写项目路径，不要带域名和 .git
# ============================================================

# 以下内容由上面的配置自动生成，无需修改。
SSH_KEY_FILE="${HOME_DIR}/.ssh/id_ed25519"
SSH_KEY_PASSPHRASE=""
SSH_KEYS_URL="https://${GIT_SERVER_HOST}/-/user_settings/ssh_keys"
PROJECT_SSH_URL="git@${GIT_SERVER_HOST}:${PROJECT_PATH}.git"
CLONE_PARENT_DIR="${HOME_DIR}"

log() {
  printf '\n\033[1;32m==> %s\033[0m\n' "$*"
}

warn() {
  printf '\033[1;33m警告：%s\033[0m\n' "$*" >&2
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || {
    printf '缺少命令：%s\n' "$1" >&2
    exit 1
  }
}

install_xclip_if_possible() {
  if command -v xclip >/dev/null 2>&1; then
    return
  fi

  if command -v apt-get >/dev/null 2>&1; then
    log "安装 xclip"
    apt-get update
    apt-get install -y xclip
  else
    warn "系统没有 apt-get，无法自动安装 xclip；公钥仍会输出到终端。"
  fi
}

add_known_host() {
  local host="$1"
  if as_user ssh-keygen -F "$host" -f "${HOME_DIR}/.ssh/known_hosts" >/dev/null 2>&1; then
    return
  fi

  log "获取并记录主机密钥：${host}"
  warn "首次使用时，请通过可信渠道核对 ${host} 的 SSH 主机指纹。"
  ssh-keyscan -H "$host" >> "${HOME_DIR}/.ssh/known_hosts"
  chown "$CURRENT_USER:$CURRENT_GROUP" "${HOME_DIR}/.ssh/known_hosts"
}

test_ssh_host() {
  local host="$1"
  log "测试 SSH 连通性：git@${host}"
  # GitLab 成功认证时也可能以非 0 状态退出，因此只展示结果，不中断脚本。
  as_user ssh -o ConnectTimeout=10 -T "git@${host}" || true
}

require_command ssh-keygen
require_command ssh
require_command ssh-keyscan
require_command git

printf '\n请先使用浏览器登录 GitLab 网站。\n'
printf 'SSH 密钥配置页面：%s\n\n' "$SSH_KEYS_URL"
read -r -p "确认已经登录 GitLab 后，按 Enter 开始配置... "

log "准备 SSH 目录"
install -d -m 700 -o "$CURRENT_USER" -g "$CURRENT_GROUP" "${HOME_DIR}/.ssh"

if [[ -e "$SSH_KEY_FILE" || -e "${SSH_KEY_FILE}.pub" ]]; then
  if [[ -f "$SSH_KEY_FILE" && -f "${SSH_KEY_FILE}.pub" ]]; then
    log "发现已有密钥，将直接复用：${SSH_KEY_FILE}"
    chown "$CURRENT_USER:$CURRENT_GROUP" "$SSH_KEY_FILE" "${SSH_KEY_FILE}.pub"
  else
    printf '密钥文件不完整，请先检查：%s 和 %s.pub\n' \
      "$SSH_KEY_FILE" "$SSH_KEY_FILE" >&2
    exit 1
  fi
else
  log "生成 ED25519 SSH 密钥"
  as_user ssh-keygen \
    -t ed25519 \
    -C "$GIT_USER_EMAIL" \
    -f "$SSH_KEY_FILE" \
    -N "$SSH_KEY_PASSPHRASE"
fi

as_user chmod 600 "$SSH_KEY_FILE"
as_user chmod 644 "${SSH_KEY_FILE}.pub"
as_user touch "${HOME_DIR}/.ssh/known_hosts"
as_user chmod 600 "${HOME_DIR}/.ssh/known_hosts"

install_xclip_if_possible
if command -v xclip >/dev/null 2>&1 && [[ -n "${DISPLAY:-}" ]]; then
  as_user env DISPLAY="$DISPLAY" XAUTHORITY="${XAUTHORITY:-${HOME_DIR}/.Xauthority}" \
    xclip -selection clipboard < "${SSH_KEY_FILE}.pub"
  log "公钥已复制到剪贴板"
else
  warn "当前环境无法使用图形剪贴板，请手动复制下方公钥。"
fi

printf '\n请复制下面的数据，粘贴到 GitLab SSH Key 输入框：\n'
printf '粘贴页面：%s\n' "$SSH_KEYS_URL"
printf '\n----- 需要粘贴的数据 -----\n'
cat "${SSH_KEY_FILE}.pub"
printf '%s\n\n' '----------------------------'
printf 'GitLab 账号邮箱：%s\n' "$GIT_USER_EMAIL"
read -r -p "请打开上述链接并粘贴、保存公钥，完成后按 Enter 继续... "

add_known_host "$GIT_SERVER_HOST"
test_ssh_host "$GIT_SERVER_HOST"

log "设置 Git 全局用户信息"
as_user git config --global user.name "$GIT_USER_NAME"
as_user git config --global user.email "$GIT_USER_EMAIL"
printf 'user.name=%s\n' "$(as_user git config --global user.name)"
printf 'user.email=%s\n' "$(as_user git config --global user.email)"

project_dir="${CLONE_PARENT_DIR%/}/${PROJECT_SSH_URL##*/}"
project_dir="${project_dir%.git}"
if [[ -e "$project_dir" ]]; then
  warn "目标目录已存在，跳过克隆：${project_dir}"
else
  log "克隆项目到 ${CLONE_PARENT_DIR}"
  as_user mkdir -p "$CLONE_PARENT_DIR"
  as_user git -C "$CLONE_PARENT_DIR" clone "$PROJECT_SSH_URL"
fi

log "配置完成"
