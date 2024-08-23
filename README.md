# UFW 放行系统已监听端口自动化工具

**一键命令**

    wget --no-check-certificate -O ufw.sh https://raw.githubusercontent.com/huangxm168/UFW-Allow-Listening-Ports-Automation/main/ufw.sh && chmod +x ufw.sh && sudo ./ufw.sh

**脚本功能概述：**

该脚本用于在 Debian 系统中自动检测现有的防火墙配置，基于特定条件安装和配置 ufw 防火墙，设置基础的安全规则，并通过 ufw 自动放行当前系统正在监听的所有端口，从而确保系统的安全性和服务的正常运行。

**运行流程逻辑：**

1. 权限检测：首先检测是否以 root 用户或具有 sudo 权限的用户运行。如果不是，脚本将提示并退出。
2. 防火墙检测：检测系统中是否安装了 iptables、nftables、ufw 和 firewalld。根据检测结果，判断是否需要安装 ufw。
3. 安装 ufw：在符合特定防火墙配置的情况下，脚本会自动安装 ufw，并在安装成功后输出提示信息。
4. 防火墙规则设置：如果 ufw 安装成功，脚本将配置基本的防火墙规则，允许所有出站流量，禁止所有入站流量，放行 HTTP 和 HTTPS 流量。
5. 监听端口检测和放行：脚本会检测系统中已监听的端口，并使用 ufw 依次放行这些端口，确保现有服务正常运行。
6. 启用防火墙：最后，脚本会启用 ufw 防火墙，并提示用户防火墙已成功启用。

**脚本运行要求**

- 已安装 wget
- root 用户或使用 sudo 命令

**已验证系统**

- [x] Debian 11
- [x] Debian 12
