#!/bin/bash

# PlantScience.AI 网站切换脚本
# 用于在正常模式和维护模式之间切换

NGINX_CONF="/www/server/panel/vhost/nginx/plantscience.ai.conf"
NORMAL_ROOT="/www/wwwroot/plantscience.ai/dist"
MAINTENANCE_ROOT="/www/wwwroot/plantscience_ai_maintenance/dist"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查是否以 root 权限运行
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}错误: 请使用 root 权限运行此脚本${NC}"
    echo "用法: sudo $0 [normal|maintenance|status]"
    exit 1
fi

# 获取当前状态
get_current_status() {
    if grep -q "root $MAINTENANCE_ROOT" "$NGINX_CONF"; then
        echo "maintenance"
    elif grep -q "root $NORMAL_ROOT" "$NGINX_CONF"; then
        echo "normal"
    else
        echo "unknown"
    fi
}

# 显示当前状态
show_status() {
    local status=$(get_current_status)
    echo "=================================="
    echo "  PlantScience.AI 网站状态"
    echo "=================================="
    case $status in
        "normal")
            echo -e "当前模式: ${GREEN}正常运行${NC}"
            echo "Root 目录: $NORMAL_ROOT"
            ;;
        "maintenance")
            echo -e "当前模式: ${YELLOW}维护中${NC}"
            echo "Root 目录: $MAINTENANCE_ROOT"
            ;;
        *)
            echo -e "当前模式: ${RED}未知${NC}"
            echo "请检查 Nginx 配置文件"
            ;;
    esac
    echo "=================================="
}

# 切换到维护模式
switch_to_maintenance() {
    local current=$(get_current_status)
    if [ "$current" = "maintenance" ]; then
        echo -e "${YELLOW}已经处于维护模式${NC}"
        return 0
    fi

    echo "正在切换到维护模式..."
    sed -i "s|root $NORMAL_ROOT|root $MAINTENANCE_ROOT|g" "$NGINX_CONF"

    # 测试 Nginx 配置
    if nginx -t 2>/dev/null; then
        nginx -s reload
        echo -e "${GREEN}✓ 已切换到维护模式${NC}"
        return 0
    else
        # 回滚
        sed -i "s|root $MAINTENANCE_ROOT|root $NORMAL_ROOT|g" "$NGINX_CONF"
        echo -e "${RED}✗ Nginx 配置测试失败，已回滚${NC}"
        return 1
    fi
}

# 切换到正常模式
switch_to_normal() {
    local current=$(get_current_status)
    if [ "$current" = "normal" ]; then
        echo -e "${YELLOW}已经处于正常模式${NC}"
        return 0
    fi

    echo "正在切换到正常模式..."
    sed -i "s|root $MAINTENANCE_ROOT|root $NORMAL_ROOT|g" "$NGINX_CONF"

    # 测试 Nginx 配置
    if nginx -t 2>/dev/null; then
        nginx -s reload
        echo -e "${GREEN}✓ 已切换到正常模式${NC}"
        return 0
    else
        # 回滚
        sed -i "s|root $NORMAL_ROOT|root $MAINTENANCE_ROOT|g" "$NGINX_CONF"
        echo -e "${RED}✗ Nginx 配置测试失败，已回滚${NC}"
        return 1
    fi
}

# 一键切换（自动判断当前状态并切换）
toggle() {
    local current=$(get_current_status)
    case $current in
        "normal")
            switch_to_maintenance
            ;;
        "maintenance")
            switch_to_normal
            ;;
        *)
            echo -e "${RED}无法判断当前状态，请手动指定模式${NC}"
            exit 1
            ;;
    esac
}

# 显示帮助
show_help() {
    echo "用法: $0 [命令]"
    echo ""
    echo "命令:"
    echo "  status       显示当前状态"
    echo "  normal       切换到正常模式"
    echo "  maintenance  切换到维护模式"
    echo "  toggle       一键切换（自动判断并切换到另一模式）"
    echo "  help         显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  sudo $0 toggle       # 一键切换"
    echo "  sudo $0 maintenance  # 切换到维护模式"
    echo "  sudo $0 normal       # 切换到正常模式"
}

# 主逻辑
case "${1:-toggle}" in
    "status")
        show_status
        ;;
    "normal")
        switch_to_normal
        show_status
        ;;
    "maintenance")
        switch_to_maintenance
        show_status
        ;;
    "toggle")
        toggle
        show_status
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        echo -e "${RED}未知命令: $1${NC}"
        show_help
        exit 1
        ;;
esac
