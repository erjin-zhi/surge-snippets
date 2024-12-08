# Surge Snippets

这是一个 Surge 配置和脚本的集合仓库，包含了各种实用的配置片段和自动化脚本。

## 目录

### 服务器脚本
- [Snell 服务器](/snell-server) - Snell v4 服务器一键安装脚本
  - 支持 IPv4/IPv6
  - 自动生成配置
  - 完整的服务管理功能

### 配置片段
- [Google 重定向](/surge/modules/Google_Rewrite.sgmodule) - 将 Google CN 重定向到 Google.com
  - 支持 www.g.cn 和 www.google.cn
  - 自动 MITM 处理

### 代理工具
- [GOST 代理服务器](/gost) - 基于 GOST 的 SNI 代理服务器
  - 支持 80/443 端口监听
  - 自动 SNI/Host 识别转发
  - 完整配置文档

- [GRE 隧道](/gre) - Linux GRE 隧道配置教程
  - 包含防火墙配置
  - NAT 和转发规则设置
  - 完整部署文档

## 贡献指南

欢迎提交 Pull Request 来完善这个仓库。在提交之前，请确保：

1. 代码经过测试
2. 提供清晰的文档说明
3. 遵循项目的目录结构

## 许可证

MIT License
