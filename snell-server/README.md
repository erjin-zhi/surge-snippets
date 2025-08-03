# Snell 服务器安装指南

自动安装和配置 Snell v4 服务器的脚本。

## 快速安装

执行以下命令安装 Snell 服务器:

```bash
mkdir -p snell-server && cd snell-server && wget -O install.sh https://raw.githubusercontent.com/erjin-zhi/surge-snippets/main/snell-server/install-snell.sh && chmod +x install.sh && ./install.sh
```

## 功能特点

- ✨ 自动安装最新版本 Snell v4 服务器
- 🔄 自动生成随机端口和密钥
- 🌐 支持 IPv4/IPv6 双栈
- 🚀 自动配置系统服务
- 📱 自动生成 Surge 客户端配置
- 💻 完整的服务管理功能

## 使用说明

安装完成后，可以使用以下命令管理服务：

- 查看服务状态：`systemctl status snell-server`
- 启动服务：`systemctl start snell-server`
- 停止服务：`systemctl stop snell-server`
- 重启服务：`systemctl restart snell-server`
- 查看服务日志：`journalctl -u snell-server -f`

## 配置文件

- 配置文件路径：`/etc/snell/config.conf`
- 程序路径：`/usr/local/bin/snell-server`

## 卸载说明

重新运行安装脚本，选择选项 3 即可卸载服务。卸载时可以选择是否保留配置文件。

## 注意事项

1. 脚本需要 root 权限运行
2. 支持 Debian/Ubuntu 和 CentOS/RHEL 系统
3. 自动安装所需依赖（unzip、wget、curl）
4. 支持重复运行，可用于升级或重新配置