# 添加 IP 获取函数
get_ip_address() {
    local type=$1  # ipv4 或 ipv6
    local ip=""
    local services=(
        "ip.sb"
        "ifconfig.co"
        "api.ipify.org"
        "icanhazip.com"
    )
    
    if [ "$type" = "ipv4" ]; then
        # 首先尝试从网卡获取
        ip=$(ip -4 addr show scope global | grep inet | awk '{print $2}' | cut -d/ -f1 | head -n 1)
        if [ -z "$ip" ]; then
            # 如果网卡获取失败，尝试在线服务
            for service in "${services[@]}"; do
                ip=$(curl -s4 $service 2>/dev/null)
                if [ ! -z "$ip" ] && [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                    break
                fi
            done
        fi
    elif [ "$type" = "ipv6" ]; then
        # 首先尝试从网卡获取
        ip=$(ip -6 addr show scope global | grep inet6 | awk '{print $2}' | cut -d/ -f1 | head -n 1)
        if [ -z "$ip" ]; then
            # 如果网卡获取失败，尝试在线服务
            for service in "${services[@]}"; do
                ip=$(curl -s6 $service 2>/dev/null)
                if [ ! -z "$ip" ] && [[ $ip =~ ^[0-9a-fA-F:]+$ ]]; then
                    break
                fi
            done
        fi
    fi
    
    echo "$ip"
}

# 修改 print_service_details 函数中的 IP 获取部分
print_service_details() {
    if systemctl is-active --quiet ${SERVICE_NAME}; then
        local config_file="${CONFIG_DIR}/config.conf"
        local port=$(grep "listen" "$config_file" | cut -d: -f2)
        local psk=$(grep "psk" "$config_file" | cut -d= -f2 | tr -d ' ')
        local public_ipv4=$(get_ip_address "ipv4")
        local public_ipv6=$(get_ip_address "ipv6")
        
        # ... (前面的代码保持不变)
        
        # 网络配置信息
        echo -e "${BOLD}${CYAN}🌐 Network Configuration${NC}"
        echo -e "  ${BOLD}Local Port${NC}        🔌 ${port}"
        if [ ! -z "$public_ipv4" ]; then
            echo -e "  ${BOLD}IPv4 Address${NC}     📍 ${BLUE}${public_ipv4}${NC}"
        fi
        if [ ! -z "$public_ipv6" ]; then
            echo -e "  ${BOLD}IPv6 Address${NC}     📍 ${BLUE}${public_ipv6}${NC}"
        fi
        print_separator
        
        # ... (后面的代码保持不变)
        
        # Surge 配置
        echo -e "${BOLD}${CYAN}📱 Client Configuration${NC}"
        echo -e "  ${BOLD}[Snell]${NC}"
        if [ ! -z "$public_ipv4" ]; then
            echo -e "  server = ${public_ipv4}"
        elif [ ! -z "$public_ipv6" ]; then
            echo -e "  server = ${public_ipv6}"
        fi
        echo -e "  port = ${port}"
        echo -e "  psk = ${psk}"
        echo -e "  version = 4"
        print_separator
    fi
}
#!/bin/bash

# 颜色和样式定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
BOLD='\033[1m'
NC='\033[0m'

# 配置变量
SNELL_VERSION="v4.1.1"
DOWNLOAD_URL="https://dl.nssurge.com/snell/snell-server-${SNELL_VERSION}-linux-amd64.zip"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/snell"
SERVICE_NAME="snell-server"

# IP地址获取函数
get_ip_address() {
    local type=$1  # ipv4 或 ipv6
    local ip=""
    local services=(
        "ip.sb"
        "ifconfig.co"
        "api.ipify.org"
        "icanhazip.com"
    )

    if [ "$type" = "ipv4" ]; then
        # 首先尝试从网卡获取
        ip=$(ip -4 addr show scope global | grep inet | awk '{print $2}' | cut -d/ -f1 | head -n 1)
        if [ -z "$ip" ]; then
            # 如果网卡获取失败，尝试在线服务
            for service in "${services[@]}"; do
                ip=$(curl -s4 $service 2>/dev/null)
                if [ ! -z "$ip" ] && [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                    break
                fi
            done
        fi
    elif [ "$type" = "ipv6" ]; then
        # 首先尝试从网卡获取
        ip=$(ip -6 addr show scope global | grep inet6 | awk '{print $2}' | cut -d/ -f1 | head -n 1)
        if [ -z "$ip" ]; then
            # 如果网卡获取失败，尝试在线服务
            for service in "${services[@]}"; do
                ip=$(curl -s6 $service 2>/dev/null)
                if [ ! -z "$ip" ] && [[ $ip =~ ^[0-9a-fA-F:]+$ ]]; then
                    break
                fi
            done
        fi
    fi

    echo "$ip"
}

# 打印分隔线
print_separator() {
    echo -e "${GRAY}--------------------${NC}"
}

# 打印标题
print_title() {
    echo -e "\n${BOLD}${CYAN}$1${NC}"
    print_separator
}

# 打印状态信息
print_status() {
    local status=$1
    local message=$2
    case $status in
        "success")
            echo -e "✅ ${message}"
            ;;
        "error")
            echo -e "❌ ${message}"
            ;;
        "info")
            echo -e "ℹ️  ${message}"
            ;;
        "warning")
            echo -e "⚠️  ${message}"
            ;;
    esac
}

# 检查是否为root用户
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_status "error" "此脚本必须以root权限运行"
        exit 1
    fi
    print_status "success" "权限检查通过"
}

# 检查并安装依赖
install_dependencies() {
    local needs_install=0
    local packages=()

    print_title "📦 依赖检查"
    for cmd in unzip wget curl; do
        if ! command -v $cmd >/dev/null 2>&1; then
            packages+=("$cmd")
            needs_install=1
            print_status "warning" "未找到 ${cmd}，将进行安装"
        else
            print_status "success" "${cmd} 已安装"
        fi
    done

    if [ $needs_install -eq 1 ]; then
        if command -v apt >/dev/null 2>&1; then
            apt update -qq
            apt install -y "${packages[@]}"
        elif command -v yum >/dev/null 2>&1; then
            yum install -y "${packages[@]}"
        else
            print_status "error" "无法确定包管理器，请手动安装所需依赖"
            exit 1
        fi
    fi
}

# 生成随机端口和密码
generate_config() {
    local port=$(shuf -i 10000-65535 -n 1)
    local psk="$(openssl rand -base64 16)"

    mkdir -p "$CONFIG_DIR"

    if [ -f "${CONFIG_DIR}/config.conf" ]; then
        print_status "warning" "检测到已存在的配置文件"
        echo -e "${YELLOW}当前配置:${NC}"
        cat "${CONFIG_DIR}/config.conf"
        echo
        read -p "是否要重新生成配置？(y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "success" "保留现有配置文件"
            return
        fi
    fi

    cat > "${CONFIG_DIR}/config.conf" << EOF
[snell-server]
listen = 0.0.0.0:${port}
psk = ${psk}
ipv6 = true
obfs = http
EOF
    print_status "success" "配置文件已生成"
}

# 创建systemd服务
create_service() {
    cat > /etc/systemd/system/${SERVICE_NAME}.service << EOF
[Unit]
Description=Snell Server
After=network.target

[Service]
Type=simple
LimitNOFILE=32768
ExecStart=${INSTALL_DIR}/snell-server -c ${CONFIG_DIR}/config.conf
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=snell-server
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable ${SERVICE_NAME}
    systemctl start ${SERVICE_NAME}
}

# 打印服务详细信息
print_service_details() {
    if systemctl is-active --quiet ${SERVICE_NAME}; then
        local config_file="${CONFIG_DIR}/config.conf"
        local port=$(grep "listen" "$config_file" | cut -d: -f2)
        local psk=$(grep "psk" "$config_file" | cut -d= -f2 | tr -d ' ')
        local public_ipv4=$(get_ip_address "ipv4")
        local public_ipv6=$(get_ip_address "ipv6")

        print_title "🚀 Snell Server Status"

        # 系统状态信息
        echo -e "\n${BOLD}${CYAN}⚙️  System Status${NC}"
        echo -e "  ${BOLD}Runtime Status${NC}    ${GREEN}●${NC} Running"
        echo -e "  ${BOLD}Auto Startup${NC}      ${GREEN}●${NC} Enabled"
        echo -e "  ${BOLD}Memory Usage${NC}      💾 $(ps -o rss= -p $(pgrep -f "snell-server") | awk '{printf "%.1f MB", $1/1024}')"
        echo -e "  ${BOLD}Version${NC}           📦 ${SNELL_VERSION}"
        print_separator

        # 网络配置信息
        echo -e "${BOLD}${CYAN}🌐 Network Configuration${NC}"
        echo -e "  ${BOLD}Local Port${NC}        🔌 ${port}"
        if [ ! -z "$public_ipv4" ]; then
            echo -e "  ${BOLD}IPv4 Address${NC}     📍 ${BLUE}${public_ipv4}${NC}"
        fi
        if [ ! -z "$public_ipv6" ]; then
            echo -e "  ${BOLD}IPv6 Address${NC}     📍 ${BLUE}${public_ipv6}${NC}"
        fi
        print_separator

        # 连接信息
        echo -e "${BOLD}${CYAN}🔑 Connection Details${NC}"
        echo -e "  ${BOLD}PSK Key${NC}           ${YELLOW}${psk}${NC}"
        print_separator

        # Surge 配置
        echo -e "${BOLD}${CYAN}📱 Client Configuration${NC}"
        echo -e "  ${BOLD}[Snell]${NC}"
        if [ ! -z "$public_ipv4" ]; then
            echo -e "  server = ${public_ipv4}"
        elif [ ! -z "$public_ipv6" ]; then
            echo -e "  server = ${public_ipv6}"
        fi
        echo -e "  port = ${port}"
        echo -e "  psk = ${psk}"
        echo -e "  version = 4"
        print_separator
    else
        print_title "❌ SNELL SERVER STATUS"
        echo -e "\n${BOLD}Service Status:${NC}    ${RED}Not Running${NC}"
        print_separator
    fi
    print_usage_guide
}

# 卸载服务
uninstall_service() {
    print_title "🗑️  卸载 Snell 服务"

    if systemctl is-active --quiet ${SERVICE_NAME}; then
        systemctl stop ${SERVICE_NAME}
        print_status "success" "服务已停止"
    fi

    systemctl disable ${SERVICE_NAME} 2>/dev/null
    rm -f /etc/systemd/system/${SERVICE_NAME}.service
    systemctl daemon-reload

    read -p "是否要保留配置文件？(y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        rm -rf ${CONFIG_DIR}
        print_status "success" "配置文件已删除"
    else
        print_status "success" "配置文件已保留"
    fi

    rm -f ${INSTALL_DIR}/snell-server
    print_status "success" "Snell服务已完全卸载"
    print_separator
}

# 主安装流程
install_snell() {
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"

    print_title "📥 安装 Snell Server ${SNELL_VERSION}"

    # 下载和解压
    print_status "info" "下载服务器文件..."
    wget -q --show-progress "$DOWNLOAD_URL"
    if [ $? -ne 0 ]; then
        print_status "error" "下载失败，请检查网络连接"
        exit 1
    fi

    print_status "info" "解压文件..."
    unzip -q "snell-server-${SNELL_VERSION}-linux-amd64.zip"
    if [ $? -ne 0 ]; then
        print_status "error" "解压失败"
        exit 1
    fi

    chmod +x snell-server
    mv snell-server "$INSTALL_DIR"

    cd - > /dev/null
    rm -rf "$temp_dir"

    generate_config
    create_service

    if systemctl is-active --quiet ${SERVICE_NAME}; then
        print_status "success" "安装完成并成功启动服务"
        return 0
    else
        print_status "error" "服务启动失败"
        return 1
    fi
}

# 启动服务
start_service() {
    systemctl start ${SERVICE_NAME}
    if systemctl is-active --quiet ${SERVICE_NAME}; then
        print_status "success" "服务已启动"
        return 0
    else
        print_status "error" "服务启动失败"
        return 1
    fi
}

# 打印操作命令
print_usage_guide() {
    echo
    print_title "📖 使用指南"
    echo -e "${BOLD}${CYAN}常用管理命令:${NC}"
    echo -e "  ${YELLOW}查看服务状态:${NC}"
    echo -e "    systemctl status snell-server"
    echo
    echo -e "  ${YELLOW}启动服务:${NC}"
    echo -e "    systemctl start snell-server"
    echo
    echo -e "  ${YELLOW}停止服务:${NC}"
    echo -e "    systemctl stop snell-server"
    echo
    echo -e "  ${YELLOW}重启服务:${NC}"
    echo -e "    systemctl restart snell-server"
    echo
    echo -e "  ${YELLOW}查看服务日志:${NC}"
    echo -e "    journalctl -u snell-server -n 50 --no-pager"
    echo -e "    journalctl -u snell-server -f"
    echo
    echo -e "  ${YELLOW}配置文件位置:${NC}"
    echo -e "    ${CONFIG_DIR}/config.conf"
    echo
    echo -e "  ${YELLOW}程序文件位置:${NC}"
    echo -e "    ${INSTALL_DIR}/snell-server"
    print_separator
}

# 主函数
main() {
    clear
    print_title "🚀 Snell Server 管理脚本"
    print_status "info" "📦 版本: ${SNELL_VERSION}"
    echo

    check_root
    install_dependencies

    if [ -f "${INSTALL_DIR}/snell-server" ]; then
        if systemctl is-active --quiet ${SERVICE_NAME}; then
            print_service_details
        else
            print_status "warning" "服务未运行"
            read -p "是否要启动服务？(y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                if start_service; then
                    print_service_details
                else
                    journalctl -u ${SERVICE_NAME} --no-pager -n 20
                fi
            fi
        fi

        echo -e "\n${BOLD}${CYAN}⚡️ 请选择操作：${NC}"
        echo -e "  ${BLUE}1${NC}. 保持当前状态 ${GREEN}[默认]${NC}"
        echo -e "  ${BLUE}2${NC}. 重新安装"
        echo -e "  ${BLUE}3${NC}. 卸载服务"
        read -p "请输入选项 [1-3] (默认: 1): " choice
        echo

        case ${choice:-1} in
            1)
                print_status "success" "操作已完成"
                ;;
            2)
                uninstall_service
                install_snell && print_service_details
                ;;
            3)
                uninstall_service
                ;;
            *)
                print_status "error" "无效的选项"
                exit 1
                ;;
        esac
    else
        install_snell && print_service_details
    fi
}

main
