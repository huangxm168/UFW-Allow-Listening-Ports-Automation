#!/bin/bash

# 颜色定义
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[93m"
BLUE="\e[34m"
CYAN="\e[36m"     # 青色
MAGENTA="\e[35m"  # 洋红色
RESET="\e[0m"

# 打印欢迎横幅
echo ""
echo -e "-------- Welcome to the UFW Allow Listening Ports Automation --------"
echo ""
echo ""
echo ""
echo -e " █████   █████  ███         █████   █████ █████ █████ ██████   ██████
░░███   ░░███  ░░░         ░░███   ░░███ ░░███ ░░███ ░░██████ ██████ 
 ░███    ░███  ████         ░███    ░███  ░░███ ███   ░███░█████░███ 
 ░███████████ ░░███         ░███████████   ░░█████    ░███░░███ ░███ 
 ░███░░░░░███  ░███         ░███░░░░░███    ███░███   ░███ ░░░  ░███ 
 ░███    ░███  ░███         ░███    ░███   ███ ░░███  ░███      ░███ 
 █████   █████ █████  ██    █████   █████ █████ █████ █████     █████
░░░░░   ░░░░░ ░░░░░  ██    ░░░░░   ░░░░░ ░░░░░ ░░░░░ ░░░░░     ░░░░░ 
                    ░░                                               
                                                                     
                                                                     "
echo -e "------------- 欢迎使用 UFW 放行系统已监听端口自动化脚本 -------------"

# 检测是否以 root 用户或具有 sudo 权限的用户运行脚本
if [ "$EUID" -ne 0 ]; then
    echo ""
    echo -e "${RED}检测到当前用户非 root 用户，或没有使用 sudo 命令运行脚本！${RESET}"
    echo ""
    echo -e "${YELLOW}请切换为 root 用户或使用 sudo 命令运行该脚本。${RESET}"
    echo ""
    echo -e "${MAGENTA}脚本已自动退出。${RESET}"
    exit 1
fi

# 系统更新
echo ""
echo -e "${YELLOW}正在更新系统并安装环境依赖……${RESET}"
apt update > /dev/null && apt upgrade -y > /dev/null
if [ $? -ne 0 ]; then
    echo -e "${RED}系统和软件更新失败，请检查相关错误，或手动更新后再次运行脚本。${RESET}"
    echo ""
    echo -e "${MAGENTA}脚本已自动退出。${RESET}"
    exit 1
fi
echo -e "${GREEN}已成功更新系统和软件！${RESET}"

# 输出文本“正在检测当前系统的防火墙配置和状态...”
echo ""
echo -e "${YELLOW}正在检测当前系统的防火墙配置和状态...${RESET}"

# 检测防火墙是否安装，并将结果设定为变量
dpkg -l | grep -q iptables && iptables_installed=true || iptables_installed=false
dpkg -l | grep -q nftables && nftables_installed=true || nftables_installed=false
dpkg -l | grep -q ufw && ufw_installed=true || ufw_installed=false
dpkg -l | grep -q firewalld && firewalld_installed=true || firewalld_installed=false

# 输出检测结果
$iptables_installed && echo -e "${BLUE}检测到 iptables 已安装。${RESET}"
$nftables_installed && echo -e "${BLUE}检测到 nftables 已安装。${RESET}"
$ufw_installed && echo -e "${BLUE}检测到 ufw 已安装。${RESET}"
$firewalld_installed && echo -e "${BLUE}检测到 firewalld 已安装。${RESET}"

# 根据检测结果进行逻辑判断
if $ufw_installed && ! $firewalld_installed; then
    echo ""
    echo -e "${YELLOW}检测到 ufw 已安装且未安装 firewalld。${RESET}"
    echo -e "${BLUE}已跳过 ufw 安装步骤。${RESET}"
else
    if $iptables_installed || $nftables_installed; then
        echo ""
        echo -e "${YELLOW}当前系统的防火墙配置和状态符合要求，正在安装 ufw...${RESET}"
        apt install ufw -y > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo -e "${RED}ufw 安装失败，脚本已退出。${RESET}"
            exit 1
        else
            echo -e "${GREEN}ufw 安装成功！${RESET}"
        fi
    else
        echo ""
        echo -e "${RED}检测到系统中的防火墙配置或状态不符合脚本运行条件。${RESET}"
        echo ""
        echo -e "${MAGENTA}脚本已自动退出。${RESET}"
        exit 1
    fi
fi

# 检查并设置 ufw 规则
echo ""
echo -e "${YELLOW}正在检查防火墙配置，并准备设置 ufw 规则...${RESET}"

# 检查和设置出站规则
if ufw status | grep -q "allow (out)"; then
    echo ""
    echo -e "${BLUE}已检测到允许所有出站流量的规则，跳过相关设置。${RESET}"
else
    echo ""
    echo -e "${YELLOW}正在放行所有出站流量...${RESET}"
    ufw default allow outgoing > /dev/null 2>&1
    echo -e "${GREEN}已允许所有出站流量。${RESET}"
fi

# 检查和设置入站规则
if ufw status | grep -q "deny (in)"; then
    echo ""
    echo -e "${BLUE}已检测到禁止所有入站流量的规则，跳过相关设置。${RESET}"
else
    echo ""
    echo -e "${YELLOW}正在禁止所有入站流量...${RESET}"
    ufw default deny incoming > /dev/null 2>&1
    echo -e "${GREEN}已禁止所有入站流量。${RESET}"
fi

# 检查并设置 HTTP 入站规则
if ufw status | grep -q "80/tcp ALLOW IN"; then
    echo ""
    echo -e "${BLUE}已检测到允许 HTTP 入站流量的规则，跳过相关设置。${RESET}"
else
    echo ""
    echo -e "${YELLOW}正在放行 HTTP 入站流量...${RESET}"
    ufw allow 80/tcp > /dev/null 2>&1
    echo -e "${GREEN}已允许 HTTP 入站流量。${RESET}"
fi

# 检查并设置 HTTPS 入站规则
if ufw status | grep -q "443/tcp ALLOW IN"; then
    echo ""
    echo -e "${BLUE}已检测到允许 HTTPS 入站流量的规则，跳过相关设置。${RESET}"
else
    echo ""
    echo -e "${YELLOW}正在放行 HTTPS 入站流量...${RESET}"
    ufw allow 443/tcp > /dev/null 2>&1
    echo -e "${GREEN}已允许 HTTPS 入站流量。${RESET}"
fi

# 检查并设置 SSH 入站规则
if ufw status | grep -q "22/tcp ALLOW IN"; then
    echo ""
    echo -e "${BLUE}已检测到允许 SSH 默认端口的入站流量规则，跳过相关设置。${RESET}"
else
    echo ""
    echo -e "${YELLOW}正在放行 SSH 默认端口的入站流量...${RESET}"
    ufw allow 22/tcp > /dev/null 2>&1
    echo -e "${GREEN}已允许 SSH 默认端口的 TCP 入站流量。${RESET}"
fi

# 启用 ufw 防火墙（仅当 ufw 尚未启用时）
if ufw status | grep -q "Status: inactive"; then
    echo ""
    echo -e "${YELLOW}正在启用 ufw 防火墙...${RESET}"
    ufw enable > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}ufw 防火墙已启用！${RESET}"
    else
        echo -e "${RED}ufw 防火墙启用失败！${RESET}"
    fi
else
    echo ""
    echo -e "${YELLOW}正在检测 ufw 防火墙运行状态...${RESET}"
    echo -e "${BLUE}ufw 防火墙正在运行，无需重复启动。${RESET}"
fi

# 检测当前系统已被监听的端口号
echo ""
echo -e "${YELLOW}正在检测当前系统已被监听的端口号及其防火墙规则...${RESET}"
listening_ports=$(ss -tunlp | grep LISTEN | awk '{print $5}' | cut -d':' -f2 | sort | uniq)
echo -e "${GREEN}检测完成！${RESET}"

# 放行检测到的端口
echo ""
echo -e "${YELLOW}正在处理当前系统已被监听的端口号的防火墙配置..."
for port in $listening_ports; do
    if ufw status | grep -q "$port"; then
        echo ""
        echo -e "${BLUE}已检测到端口 $port 存在放行规则，跳过相关设置。${RESET}"
    else
        echo ""
        echo -e "${YELLOW}正在通过 ufw 放行端口 $port...${RESET}"
        ufw allow $port > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}已允许 $port 端口的入站流量。${RESET}"
        else
            echo ""
            echo -e "${RED}放行 $port 端口失败！${RESET}"
        fi
    fi
done

# 结束语
echo ""
echo -e "${GREEN}Success!"
echo -e "${GREEN}已成功完成全部配置！${RESET}"