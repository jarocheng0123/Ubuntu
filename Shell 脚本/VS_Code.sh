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

# 安装 VS Code 扩展
extensions=(
    # 中文界面：VS Code 简体中文语言包
    MS-CEINTL.vscode-language-pack-zh-hans

    # 外观：Material Design 文件图标主题
    PKief.material-icon-theme

    # 数据查看：CSV 列高亮、检查与查询
    mechatroner.rainbow-csv

    # 文档查看：在 VS Code 中预览 PDF
    tomoki1207.pdf

    # Python：语言支持、运行与调试
    ms-python.python

    # Python：类型检查与智能提示
    ms-python.vscode-pylance

    # Python：Jupyter Notebook 支持
    ms-toolsai.jupyter

    # Git：可视化提交记录与分支关系图
    mhutchie.git-graph

    # Git：增强 blame、历史记录与代码作者信息
    eamodio.gitlens

    # C/C++：代码补全、编译配置与调试
    ms-vscode.cpptools

    # CMake：Microsoft 官方 CMake 项目工具
    ms-vscode.cmake-tools

    # CMake：CMake 语法高亮
    twxs.cmake

    # ROS：ROS 工程开发与调试支持
    ros-team.ros

    # 格式化：JavaScript、JSON、Markdown 等文件格式化
    esbenp.prettier-vscode

    # 配置文件：YAML 语法校验与自动补全
    redhat.vscode-yaml

    # Shell：Shell 脚本格式化
    foxundermoon.shell-format

    # Shell：ShellCheck 静态检查
    timonwong.shellcheck

    # 编辑规范：自动应用 .editorconfig 配置
    EditorConfig.EditorConfig

    # 路径补全：自动提示项目中的文件和目录路径
    christian-kohler.path-intellisense

    # 代码注释：为警告、TODO 等注释提供颜色高亮
    aaron-bond.better-comments

    # TODO 管理：汇总并导航 TODO、FIXME 等标记
    Gruntfuggly.todo-tree

    # 拼写检查：检查代码和文档中的英文拼写
    streetsidesoftware.code-spell-checker

    # 错误提示：在代码行尾显示诊断信息
    usernamehw.errorlens

    # Markdown：目录、预览与快捷编辑工具
    yzhang.markdown-all-in-one

    # Markdown：检查 Markdown 文档的格式和规范
    DavidAnson.vscode-markdownlint

    # XML：XML 语法校验、自动补全与格式化
    redhat.vscode-xml

    # TOML：TOML 语法高亮、校验与自动补全
    tamasfe.even-better-toml

    # Makefile：Makefile 目标识别、构建与调试支持
    ms-vscode.makefile-tools

    # 十六进制：查看和编辑二进制文件
    ms-vscode.hexeditor

    # HTTP：直接在编辑器中发送 REST 请求
    humao.rest-client

    # 远程开发：通过 SSH 连接远程主机
    ms-vscode-remote.remote-ssh

    # 容器开发：在 Docker 容器内打开完整开发环境
    ms-vscode-remote.remote-containers

    # 容器：Dockerfile、Compose 与容器管理支持
    ms-azuretools.vscode-docker

    # GitHub：在编辑器中查看和管理 Pull Request 与 Issue
    GitHub.vscode-pull-request-github

    # 协作开发：实时共享项目、编辑和调试会话
    MS-vsliveshare.vsliveshare

    # 代码运行：快速运行当前代码文件或选中片段
    formulahendry.code-runner

    # 正则表达式：可视化高亮并辅助调试正则表达式
    chrmarti.regex

    # AI 编程：OpenAI Codex 扩展
    openai.chatgpt
)

for extension in "${extensions[@]}"; do
    echo "正在安装 VS Code 扩展：$extension"
    sudo -H -u "$CURRENT_USER" code --install-extension "$extension" ||
        echo "⚠️ 扩展安装失败，已跳过：$extension"
done

# 安装完成
echo -e "\033[36m======================\033[0m"
echo " ✅ VS Code 安装成功！"
echo -e "\033[36m======================\033[0m"

# 启动 VS Code：以原登录用户身份在后台打开，避免使用 root 运行
echo "正在启动 VS Code..."
sudo -H -u "$CURRENT_USER" nohup code >/dev/null 2>&1 &
