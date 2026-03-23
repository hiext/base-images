#!/usr/bin/env bash
#
# new-api 容器启动入口脚本
#
# 功能：
# - 初始化配置
# - 设置环境变量
# - 启动 new-api 服务
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
    log_info "初始化 new-api 配置..."

    # 创建必要的目录
    local directories=(
        "/data"
        "/var/log/new-api"
    )

    for dir in "${directories[@]}"; do
        if [[ ! -d "$dir" ]]; then
            log_info "创建目录: $dir"
            mkdir -p "$dir"
        fi
    done

    # 设置默认环境变量
    : "${PORT:=3000}"
    : "${TZ:=UTC}"
    : "${SESSION_SECRET:=random_session_secret}"

    # 设置时区
    if [[ "$TZ" != "UTC" ]]; then
        log_info "设置时区: $TZ"
        export TZ="$TZ"
    fi

    log_info "配置初始化完成"
}

# 函数：显示环境信息
show_info() {
    log_info "======================================"
    log_info "new-api 容器启动"
    log_info "======================================"
    log_info "监听端口: $PORT"
    log_info "时区: $TZ"
    log_info "数据目录: /data"
    log_info "日志目录: /var/log/new-api"
    log_info "======================================"
}

# 函数：启动服务
start_service() {
    log_info "启动 new-api 服务..."
    exec "$@"
}

# 主函数
main() {
    init_config
    show_info
    start_service "$@"
}

# 执行主函数
main "$@"