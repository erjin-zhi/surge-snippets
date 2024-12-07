# GOST 代理服务器

GOST 仓库地址: https://github.com/ginuerzh/gost


# GOST 配置说明

这是一个基于 GOST 的 SNI 代理配置文件说明。该配置允许根据 SNI/Host 信息自动转发 TCP 流量到目标服务器。

## 配置文件说明

配置文件 `conf-80-443-proxy.json` 包含两个主要服务:

### 1. SNI 代理 (443端口)
该服务监听443端口,用于处理HTTPS流量:

- 名称: sni-proxy-443
- 监听地址: :443
- 处理类型: tcp
- 特性:
  - 启用流量嗅探(sniffing)
  - 根据SNI信息转发到目标服务器的443端口
  
### 2. HTTP 代理 (80端口)
该服务监听80端口,用于处理HTTP流量:

- 名称: http-proxy-80  
- 监听地址: :80
- 处理类型: tcp
- 特性:
  - 启用流量嗅探(sniffing)
  - 根据Host头信息转发到目标服务器的80端口
