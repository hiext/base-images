#!/usr/bin/env bash
#
# OpenClaw 一键安装脚本
# 参考: https://github.com/ozbillwang/openclaw-in-docker
#
# 使用方法:
#   curl -fsSL https://raw.githubusercontent.com/hiext/base-images/main/openclaw/install.sh | bash
#   或
#   ./install.sh

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
info() { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warning() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; }

# 检查命令是否存在
check_command() {
    if ! command -v "$1" &> /dev/null; then
        error "$1 未安装，请先安装 $1"
        exit 1
    fi
}

# 打印 banner
print_banner() {
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║        OpenClaw Extended Installer (hiext)           ║"
    echo "║  基于官方镜像 + Python + FFmpeg 等扩展工具              ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# 检查系统要求
check_prerequisites() {
    info "检查系统要求..."
    check_command docker
    check_command docker-compose || check_command "docker compose"
    success "Docker 和 Docker Compose 已安装"
}

# 获取 Docker Compose 命令
get_compose_cmd() {
    if command -v docker-compose &> /dev/null; then
        echo "docker-compose"
    else
        echo "docker compose"
    fi
}

# 设置默认配置
setup_defaults() {
    info "设置默认配置..."

    # 工作目录
    export OPENCLAW_DIR="${OPENCLAW_DIR:-$HOME/openclaw}"
    export OPENCLAW_CONFIG_DIR="${OPENCLAW_CONFIG_DIR:-$HOME/.openclaw}"
    export OPENCLAW_DATA_DIR="${OPENCLAW_DATA_DIR:-$HOME/openclaw/data}"
    export OPENCLAW_LOGS_DIR="${OPENCLAW_LOGS_DIR:-$HOME/openclaw/logs}"

    # 端口配置
    export GATEWAY_PORT="${GATEWAY_PORT:-18789}"

    # 镜像配置
    export OPENCLAW_IMAGE="${OPENCLAW_IMAGE:-ghcr.io/hiext/openclaw:latest}"

    success "配置完成:"
    echo "  工作目录: $OPENCLAW_DIR"
    echo "  配置目录: $OPENCLAW_CONFIG_DIR"
    echo "  数据目录: $OPENCLAW_DATA_DIR"
    echo "  日志目录: $OPENCLAW_LOGS_DIR"
    echo "  镜像: $OPENCLAW_IMAGE"
}

# 创建必要的目录
create_directories() {
    info "创建必要的目录..."

    mkdir -p "$OPENCLAW_DIR"
    mkdir -p "$OPENCLAW_CONFIG_DIR/config"
    mkdir -p "$OPENCLAW_CONFIG_DIR/workspace"
    mkdir -p "$OPENCLAW_DATA_DIR"
    mkdir -p "$OPENCLAW_LOGS_DIR"

    success "目录创建完成"
}

# 下载 docker-compose.yml
download_compose_file() {
    info "下载 Docker Compose 配置..."

    local compose_file="$OPENCLAW_DIR/docker-compose.yml"

    if [ -f "$compose_file" ]; then
        warning "docker-compose.yml 已存在，是否覆盖? (y/N)"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            info "保留现有配置"
            return
        fi
    fi

    cat > "$compose_file" << 'EOF'
services:
  openclaw:
    image: ${OPENCLAW_IMAGE:-ghcr.io/hiext/openclaw:latest}
    container_name: openclaw-gateway
    ports:
      - "${GATEWAY_PORT:-18789}:18789"
    environment:
      - OPENCLAW_TZ=${OPENCLAW_TZ:-Asia/Shanghai}
      - NODE_ENV=production
      - GATEWAY_BIND=0.0.0.0
      - LOG_LEVEL=info
      - GATEWAY_ALLOW_UNCONFIGURED=true
    volumes:
      - ${OPENCLAW_DATA_DIR}:/app/data
      - ${OPENCLAW_CONFIG_DIR}/config:/app/config
      - ${OPENCLAW_LOGS_DIR}:/var/log/openclaw
      - ${OPENCLAW_CONFIG_DIR}:/home/node/.openclaw
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:18789/healthz"]
      interval: 1m
      timeout: 10s
      start_period: 60s
      retries: 5
    command: ["node", "openclaw.mjs", "gateway", "--allow-unconfigured"]
EOF

    success "docker-compose.yml 已创建"
}

# 保存环境变量
save_env_file() {
    info "保存环境配置..."

    local env_file="$OPENCLAW_DIR/.env"

    cat > "$env_file" << EOF
# OpenClaw 配置
# 生成时间: $(date)

# 目录配置
OPENCLAW_DIR=$OPENCLAW_DIR
OPENCLAW_CONFIG_DIR=$OPENCLAW_CONFIG_DIR
OPENCLAW_DATA_DIR=$OPENCLAW_DATA_DIR
OPENCLAW_LOGS_DIR=$OPENCLAW_LOGS_DIR

# 网络配置
GATEWAY_PORT=$GATEWAY_PORT

# 镜像配置
OPENCLAW_IMAGE=$OPENCLAW_IMAGE
EOF

    success "环境配置已保存到: $env_file"
}

# 启动服务
start_service() {
    info "启动 OpenClaw 服务..."

    local compose_cmd
    compose_cmd=$(get_compose_cmd)
    cd "$OPENCLAW_DIR"

    # 拉取最新镜像
    info "拉取镜像 (这可能需要几分钟)..."
    $compose_cmd pull

    # 启动服务
    $compose_cmd up -d

    success "服务已启动"
}

# 等待健康检查
wait_for_healthy() {
    info "等待服务初始化..."

    local retries=30
    local wait_time=2

    for i in $(seq 1 $retries); do
        if curl -s http://localhost:${GATEWAY_PORT}/healthz &>/dev/null; then
            success "服务健康检查通过"
            return 0
        fi

        echo -n "."
        sleep $wait_time
    done

    error "服务启动超时，请检查日志: docker compose -f $OPENCLAW_DIR/docker-compose.yml logs"
    return 1
}

# 显示完成信息
show_completion() {
    local token=""
    local token_file="$OPENCLAW_CONFIG_DIR/config/gateway.token"

    if [ -f "$token_file" ]; then
        token=$(cat "$token_file")
    fi

    echo -e "${GREEN}"
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║              OpenClaw 安装完成!                        ║"
    echo "╠════════════════════════════════════════════════════════╣"
    echo "║                                                        ║"
    echo "║  📡 Gateway:  ws://localhost:${GATEWAY_PORT}                  ║"
    echo "║  🔍 Health:   http://localhost:${GATEWAY_PORT}/healthz       ║"
    echo "║  🌐 Browser:  http://localhost:18791/                   ║"
    echo "║                                                        ║"
    echo "║  📁 工作目录:  $OPENCLAW_DIR"
    echo "║  🔧 配置目录:  $OPENCLAW_CONFIG_DIR"
    echo "║                                                        ║"
    if [ -n "$token" ]; then
        echo "║  🔑 Gateway Token:                                     ║"
        echo "║     $token"
        echo "║                                                        ║"
    fi
    echo "╠════════════════════════════════════════════════════════╣"
    echo "║  常用命令:                                             ║"
    echo "║    cd $OPENCLAW_DIR"
    echo "║    docker compose logs -f     # 查看日志              ║"
    echo "║    docker compose down        # 停止服务              ║"
    echo "║    docker compose restart     # 重启服务              ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo -e "${NC}"

    info "提示:"
    echo "  1. Token 已保存到: $OPENCLAW_CONFIG_DIR/config/gateway.token"
    echo "  2. 配置文件位置: $OPENCLAW_CONFIG_DIR/config/openclaw.json"
    echo "  3. 首次启动后建议编辑 docker-compose.yml，移除 GATEWAY_ALLOW_UNCONFIGURED"
}

# 主函数
main() {
    print_banner
    check_prerequisites
    setup_defaults
    create_directories
    download_compose_file
    save_env_file
    start_service
    wait_for_healthy
    show_completion
}

# 运行主函数
main "$@"
