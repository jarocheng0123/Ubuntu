### Ubuntu 实用操作速查手册

#### 一、系统启动与界面切换
- **进入命令行界面**：`Ctrl + Alt + F1`（F1-F6为命令行）
- **返回图形化界面**：`Ctrl + Alt + F7`（F7-F9为图形界面）
- **重启图形界面**：`sudo systemctl restart gdm3`（GNOME桌面）/ `sudo systemctl restart lightdm`（LightDM桌面）

#### 二、终端常用快捷键
| 操作          | 快捷键                | 说明                          |
|---------------|-----------------------|-----------------------------|
| 打开终端      | `Ctrl + Alt + T`      | 全局快速启动终端              |
| 新建终端      | `Ctrl + Shift + N`    | 在当前终端窗口新建独立终端    |
| 关闭终端      | `Ctrl + D`（空行）/ `Ctrl + Shift + W`（标签页） | 退出当前终端或标签页       |
| 复制          | `Ctrl + Shift + C`    | 复制选中内容（需终端支持）    |
| 粘贴          | `Ctrl + Shift + V`    | 粘贴剪贴板内容                |
| 切换标签页    | `Ctrl + Shift + ↑/↓`  | 上下切换已打开的标签页        |
| 新建标签页    | `Ctrl + Shift + T`    | 在当前窗口新建标签页          |
| 放大终端      | `Ctrl + Shift + =`    | 放大字体/界面                 |
| 缩小终端      | `Ctrl + -`            | 缩小字体/界面                 |
| 清除屏幕      | `Ctrl + L`            | 清空当前屏幕内容（保留历史）  |
| 终止任务      | `Ctrl + C`            | 强制终止当前运行的程序        |
| 光标到行首    | `Ctrl + A`            | 快速跳转至命令行开头          |
| 光标到行尾    | `Ctrl + E`            | 快速跳转至命令行末尾          |
| 命令补全      | `Tab`                 | 自动补全文件名/命令（按两次显示所有选项）|


#### 三、文件管理器（Nautilus）快捷操作  
##### **基础导航与显示**  
- **`Ctrl + H`**：显示/隐藏隐藏文件（以 `.` 开头的文件/文件夹，如 `.config`）。  
- **`Ctrl + L`**：快速定位到地址栏（输入路径后回车可跳转）。  
- **`F11`**：切换窗口全屏模式。  
- **`Ctrl + 滚轮` / `Ctrl + +/-`**：放大/缩小文件图标显示比例。  
- **`Alt + ←`** / **退格键**：返回到历史访问目录。  
- **`Alt + →`**：前进到历史访问目录。  
- **`Home 键`**：直接跳转到用户主目录（`/home/用户名`）。  
- **`Ctrl + 鼠标中键点击文件夹`**：在新标签页中打开（需鼠标支持中键功能）。 

##### **文件/文件夹操作**  
- **`F2`**：快速重命名选中的文件/文件夹（点击名称后短按 F2 更高效）。  
- **`Ctrl + C`**：复制选中项；**`Ctrl + X`**：剪切选中项；**`Ctrl + V`**：粘贴。  
- **`Delete`**：将文件/文件夹移到回收站；**`Shift + Delete`**：永久删除（不经过回收站，谨慎使用）。  
- **`Ctrl + Z`**：撤销上一步操作（如误删、误移动）。  
- **`Ctrl + A`**：全选当前目录文件；**`Ctrl + 点击`**：多选不连续文件；**`Shift + 点击`**：多选连续文件。  

##### **窗口与标签页**  
- **`Ctrl + N`**：新建独立文件管理器窗口；**`Ctrl + T`**：在当前窗口新建标签页。  
- **`Ctrl + W`**：关闭当前标签页（仅1个标签页时关闭窗口）。  
- **`F3`**：分屏查看（左右分栏，方便拖拽文件）；**`F4`**：在当前目录打开终端（路径自动定位）。  

##### **其他实用操作**  
- **`Alt + Enter`**：查看选中文件/文件夹属性（大小、权限、修改时间等）。  
- **`Ctrl + F`**：打开搜索框（搜索当前目录及子目录文件）。  
- **`Win 键（Super） + E`**：全局快速打开文件管理器。  
- **拖拽操作**：按住 `Ctrl` 拖拽为复制，按住 `Shift` 拖拽为移动（默认拖拽为移动）。  


#### 四、nano编辑器高效操作
| 操作          | 快捷键                | 说明                          |
|---------------|-----------------------|-----------------------------|
| 标记文本      | `Alt + A`             | 开始标记文本（配合方向键选择）|
| 删除标记文本  | `Ctrl + K`            | 删除标记区域（可通过`Ctrl + U`恢复）|
| 粘贴删除内容  | `Ctrl + U`            | 粘贴最近一次被删除的内容      |
| 保存文件      | `Ctrl + O`            | 保存修改（需输入文件名后回车）|
| 退出编辑器    | `Ctrl + X`            | 退出（提示保存未修改内容）    |
| 查找文本      | `Ctrl + W`            | 输入关键词搜索（`Ctrl + W`继续下一个）|
| 替换文本      | `Alt + R`             | 输入“查找内容”和“替换内容”完成替换|


#### 五、系统信息查询
| 信息类型        | 命令                          | 说明                          |
|-----------------|-----------------------------|-----------------------------|
| 内核版本        | `uname -a`                   | 显示内核版本、架构、编译时间等|
| 系统位数        | `getconf LONG_BIT`            | 输出32或64（系统位数）        |
| 系统版本        | `lsb_release -a`              | 显示Ubuntu发行版、描述等信息  |
| Ubuntu版本      | `cat /etc/lsb-release`        | 直接查看LSB版本信息（含CODENAME）|
| 系统版本名称    | `cat /etc/os-release`         | 包含PRETTY_NAME（如"Ubuntu 22.04.3 LTS"）|
| CPU信息         | `cat /proc/cpuinfo`           | 查看CPU型号、核心数、线程数等|
| 内存信息        | `cat /proc/meminfo`           | 显示总内存、可用内存、交换空间等|
| 磁盘空间        | `df -h`                       | 按可读格式显示磁盘分区使用情况（-h=Human-readable）|
| 系统启动时间    | `uptime`                      | 显示系统已运行时长、负载等    |


#### 六、用户与权限管理
| 操作          | 命令                          | 说明                          |
|---------------|-----------------------------|-----------------------------|
| 完整root环境   | `sudo -i`                   | 切换为root用户（环境变量完全继承root）|
| 简化root环境   | `sudo su`                   | 切换为root用户（保留原用户环境变量）|
| 保留用户环境   | `sudo -s`                   | 在当前用户环境下以root权限执行命令|
| 创建用户       | `sudo useradd -m 用户名`     | 创建用户并生成家目录（-m=make home）|
| 设置用户密码   | `sudo passwd 用户名`         | 为用户设置登录密码            |
| 删除用户       | `sudo userdel -r 用户名`     | 删除用户并删除家目录（-r=remove home）|
| 添加用户到sudo组| `sudo usermod -aG sudo 用户名`| 授予用户sudo权限（-a=追加，-G=组名）|
| 查看用户所属组  | `groups`                     | 显示当前用户所在的所有组      |


#### 七、基础文件操作
| 操作          | 命令                          | 说明                          |
|---------------|-----------------------------|-----------------------------|
| 重启系统      | `sudo reboot`                 | 立即重启系统                  |
| 查看所有文件  | `ls -a`                       | 显示隐藏文件（以`.`开头的文件）|
| 当前路径      | `pwd`                         | 输出当前所在目录的绝对路径    |
| 切换目录      | `cd /目标路径`                | 示例：`cd /home/user/Documents`|
| 返回上级目录   | `cd ..`                       | 注意空格（`cd..`为错误写法）  |
| 返回主目录     | `cd ~`                        | 快速跳转至用户家目录（如`/home/user`）|
| 创建文件夹    | `mkdir 目录名`                 | 示例：`mkdir my_folder`       |
| 创建多级文件夹| `mkdir -p 目录名/子目录`       | `-p`自动创建缺失的父目录      |
| 删除空文件夹  | `rmdir 目录名`                | 仅删除空目录                  |
| 删除非空文件夹| `rm -r 目录名`                | `-r`递归删除（谨慎使用！）    |
| 复制文件/目录  | `cp 源文件 目标路径`          | 示例：`cp file.txt ~/backup/`（复制文件）<br>`cp -r folder/ ~/backup/`（复制目录，-r=递归）|
| 移动/重命名文件| `mv 源文件 目标路径/新名称`   | 示例：`mv old.txt new.txt`（重命名）<br>`mv file.txt ~/backup/`（移动文件）|


#### 八、软件管理核心命令
**推荐使用 `apt` 替代 `apt-get`**
| 操作          | 命令                          | 说明                          |
|---------------|-----------------------------|-----------------------------|
| 系统升级      | `sudo apt dist-upgrade`       | 升级系统核心组件（可能调整依赖）|
| 更新包列表    | `sudo apt update`             | 同步软件源仓库的最新包信息    |
| 升级软件包    | `sudo apt upgrade`            | 升级已安装的所有可更新软件包  |
| 安装软件      | `sudo apt install 软件名`      | 示例：`sudo apt install nginx`|
| 升级指定软件  | `sudo apt upgrade 软件名`     | 仅升级单个软件包              |
| 卸载软件      | `sudo apt remove 软件名`      | 移除软件（保留配置文件）      |
| 彻底卸载软件  | `sudo apt purge 软件名`       | 移除软件及配置文件（谨慎使用）|
| 清理缓存      | `sudo apt clean`              | 删除已下载的安装包缓存（节省磁盘）|
| 查看已安装软件| `sudo dpkg -l`                | 列出所有通过dpkg安装的软件包  |
| 搜索软件包    | `apt search 关键词`            | 示例：`apt search mysql`（查找含“mysql”的软件包）|


#### 九、网络与远程管理
| 操作          | 命令                          | 说明                          |
|---------------|-----------------------------|-----------------------------|
| 查看IP地址    | `ip addr show`                | 替代`ifconfig`（需安装`net-tools`）|
| 测试网络连通性| `ping 目标IP/域名`            | 示例：`ping baidu.com`（默认发送4次）|
| 查看路由表    | `route -n`                    | 显示当前路由规则（-n=不解析域名）|
| 安装SSH服务端 | `sudo apt install openssh-server`| 启用远程SSH连接支持          |
| 远程连接      | `ssh 用户名@目标IP`            | 示例：`ssh root@192.168.1.100`|
| 生成SSH密钥对 | `ssh-keygen -t rsa -b 4096`   | 生成RSA类型密钥（-b=密钥长度）|
| 免密登录配置  | `ssh-copy-id 用户名@目标IP`     | 将本地公钥复制到远程主机（需输入密码）|


#### 十、服务与进程管理
| 操作          | 命令                          | 说明                          |
|---------------|-----------------------------|-----------------------------|
| 启动服务      | `sudo systemctl start 服务名`  | 示例：`sudo systemctl start nginx`|
| 停止服务      | `sudo systemctl stop 服务名`   | 示例：`sudo systemctl stop nginx`|
| 重启服务      | `sudo systemctl restart 服务名`| 示例：`sudo systemctl restart nginx`|
| 查看服务状态  | `sudo systemctl status 服务名` | 显示服务运行状态、日志片段等  |
| 启用开机自启  | `sudo systemctl enable 服务名` | 示例：`sudo systemctl enable nginx`|
| 禁用开机自启  | `sudo systemctl disable 服务名`| 示例：`sudo systemctl disable nginx`|
| 查看所有进程  | `ps aux`                      | 显示所有用户的进程（含CPU/内存占用）|
| 实时监控进程  | `htop`                        | 需先安装：`sudo apt install htop`（交互更友好）|
| 终止进程      | `kill -9 进程PID`             | 强制终止进程（-9=强制信号）    |


#### 十一、文件压缩与磁盘管理
| 操作          | 命令                          | 说明                          |
|---------------|-----------------------------|-----------------------------|
| 压缩目录为tar.gz| `tar -czvf 压缩包名.tar.gz 目标目录` | `-c=创建，-z=gz压缩，-v=显示过程，-f=指定文件名`|
| 解压tar.gz文件| `tar -xzvf 压缩包名.tar.gz`    | `-x=解压，-z=识别gz压缩`       |
| 压缩为zip     | `zip -r 压缩包名.zip 目标目录` | 需先安装：`sudo apt install zip`|
| 解压zip文件   | `unzip 压缩包名.zip -d 目标路径`| `-d=指定解压目录`             |
| 查看目录大小  | `du -sh 目标路径`              | `-s=汇总大小，-h=可读格式`     |
| 挂载U盘       | `sudo mount /dev/sdb1 /mnt`    | 假设U盘设备为`/dev/sdb1`（需先查看`fdisk -l`确认）|
| 查看磁盘分区  | `sudo fdisk -l`               | 列出所有磁盘分区信息          |


#### 十二、环境变量与脚本基础
| 操作          | 命令/示例                     | 说明                          |
|---------------|-----------------------------|-----------------------------|
| 临时设置环境变量| `export PATH=$PATH:/新路径`    | 当前终端生效（重启后失效）    |
| 永久设置环境变量| `echo 'export PATH=$PATH:/新路径' >> ~/.bashrc` | 用户级配置（需`source ~/.bashrc`生效）|
| 简单Shell脚本  | `nano hello.sh`<br>`#!/bin/bash`<br>`echo "当前时间：$(date)"`<br>`echo "当前用户：$(whoami)"` | 保存后执行：`chmod +x hello.sh && ./hello.sh`|


#### 十三、系统常见问题处理
1. **TTF字体乱码**  
   临时解决：`export LANG=en_US.UTF-8`（仅当前终端生效）  
   永久解决：修改`~/.bashrc`添加`export LANG=zh_CN.UTF-8`，并重启终端。

2. **系统汉化（推荐方法）**  
   ```bash
   # 安装中文语言包
   sudo apt install language-pack-zh-hans language-pack-gnome-zh-hans
   # 配置系统语言
   sudo update-locale LANG=zh_CN.UTF-8 LC_ALL=zh_CN.UTF-8
   # 安装中文输入法（Fcitx拼音）
   sudo apt install fcitx fcitx-pinyin fcitx-config-gtk
   im-config -n fcitx  # 设置默认输入法框架
   # 配置环境变量（避免程序乱码）
   echo 'export GTK_IM_MODULE=fcitx
   export QT_IM_MODULE=fcitx
   export XMODIFIERS=@im=fcitx' >> ~/.profile
   ```

3. **软件源替换（以清华源为例）**  
   ```bash
   # 备份原源文件
   sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
   # 替换为清华源（Ubuntu 22.04示例）
   sudo nano /etc/apt/sources.list
   # 内容替换为：
   deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
   deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
   deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
   deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
   # 更新源列表
   sudo apt update
   ```


#### 十四、快捷方式创建
```bash
# 进入桌面目录
cd ~/桌面
# 新建.desktop文件（以Chrome为例）
nano google-chrome.desktop
# 填写内容（模板）：
[Desktop Entry]
Encoding=UTF-8
Version=1.0
Name=Google Chrome
Comment=快速启动Chrome浏览器
Exec=/opt/google/chrome/chrome  # 程序绝对路径（需确认实际路径）
Icon=/opt/google/chrome/product_logo_256.png  # 图标绝对路径
Terminal=false
Type=Application
Categories=Network;WebBrowser;
# 保存并退出（Ctrl+O→Enter→Ctrl+X）
# 赋予执行权限
sudo chmod +x ~/桌面/google-chrome.desktop
```


**注**：手册中涉及路径（如`/opt/google/chrome`）需根据实际安装位置调整，命令行操作建议在理解后执行，避免误删系统文件。