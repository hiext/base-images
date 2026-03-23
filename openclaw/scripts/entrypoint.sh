#!/usr/bin/env bash
#
# OpenClaw 容器启动入口脚本
#
# 功能：
# - 初始化配置
# - 设置环境变量
# - 启动 OpenClaw Gateway
#

set -eo pipefail

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 函数：初始化配置
init_config() {
    log_info "初始化 OpenClaw 配置..."

    # 创建必要的目录
    local directories=(
        "/app/data"
        "/app/config"
        "/var/log/openclaw"
    )

    for dir in "${directories[@]}"; do
        if [[ ! -d "$dir" ]]; then
            log_info "创建目录: $dir"
            mkdir -p "$dir"
        fi
    done

    # 设置默认环境变量
    : "${OPENCLAW_PORT:=18789}"
    : "${OPENCLAW_BIND:=127.0.0.1}"
    : "${OPENCLAW_TZ:=UTC}"
    : "${NODE_ENV:=production}"

    # 设置时区
    if [[ "$OPENCLAW_TZ" != "UTC" ]]; then
        log_info "设置时区: $OPENCLAW_TZ"
        export TZ="$OPENCLAW_TZ"
    fi

    # 应用自定义配置（如果存在）
    if [[ -f "/app/config/openclaw.conf" ]]; then
        log_info "加载自定义配置: /app/config/openclaw.conf"
        # 这里可以添加配置文件处理逻辑
    fi

    log_info "配置初始化完成"
}

# 函数：显示环境信息
show_info() {
    log_info "======================================"
    log_info "OpenClaw 容器启动"
    log_info "======================================"
    log_info "Node.js 版本: $(node --version)"
    log_info "npm 版本: $(npm --version)"
    log_info "Python 版本: $(python3 --version)"
    log_info "FFmpeg 版本: $(ffmpeg -version | head -n1)"
    log_info "OpenClaw 版本: $(node openclaw.mjs --version 2>/dev/null || echo 'unknown')"
    log_info "绑定地址: $OPENCLAW_BIND:$OPENCLAW_PORT"
    log_info "时区: $OPENCLAW_TZ"
    log_info "环境: $NODE_ENV"
    log_info "======================================"
}

# 函数：启动服务
start_gateway() {
    log_info "启动 OpenClaw Gateway..."
    exec "$@"
}

# 主函数
main() {
    init_config
    show_info
    start_gateway "$@"
}

# 执行主函数
main "$@"