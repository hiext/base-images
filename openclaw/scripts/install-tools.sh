#!/usr/bin/env bash
#
# OpenClaw 额外工具安装脚本
#
# 功能：
# - 安装额外的调试工具和依赖
# - 支持可选工具安装
#

set -eo pipefail

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 函数：安装额外工具
install_tools() {
    log_info "安装额外工具..."

    # 检测包管理器
    if command -v apt-get > /dev/null 2>&1; then
        install_with_apt
    elif command -v apk > /dev/null 2>&1; then
        install_with_apk
    else
        log_warn "未知的包管理器，跳过工具安装"
        return 0
    fi
}

# 函数：使用 apt 安装
install_with_apt() {
    log_info "使用 apt-get 安装工具..."

    local tools=(
        # 网络工具
        "curl"
        "wget"
        "netcat-openbsd"
        "iputils-ping"
        # 文本处理
        "jq"
        "grep"
        "sed"
        "gawk"
        # 系统工具
        "psmisc"
        "htop"
        "tree"
        # 压缩工具
        "zip"
        "unzip"
        "tar"
        "gzip"
    )

    apt-get update

    for tool in "${tools[@]}"; do
        log_info "安装 $tool..."
        apt-get install -y --no-install-recommends "$tool" || log_warn "跳过 $tool (可能已安装)"
    done

    apt-get clean
    rm -rf /var/lib/apt/lists/*

    log_info "apt 工具安装完成"
}

# 函数：使用 apk 安装
install_with_apk() {
    log_info "使用 apk 安装工具..."

    local tools=(
        "curl"
        "wget"
        "netcat-openbsd"
        "jq"
        "grep"
        "tree"
        "htop"
    )

    for tool in "${tools[@]}"; do
        log_info "安装 $tool..."
        apk add --no-cache "$tool" || log_warn "跳过 $tool"
    done

    log_info "apk 工具安装完成"
}

# 函数：安装 Python 包
install_python_packages() {
    log_info "安装常用 Python 包..."

    # 检查 pip 是否可用
    if ! command -v pip3 > /dev/null 2>&1; then
        log_warn "pip3 未找到，跳过 Python 包安装"
        return 0
    fi

    # 安装常用 Python 包
    local packages=(
        "requests"
        "pyyaml"
    )

    for pkg in "${packages[@]}"; do
        log_info "安装 Python 包: $pkg"
        pip3 install --no-cache-dir "$pkg" || log_warn "跳过 $pkg"
    done

    log_info "Python 包安装完成"
}

# 主函数
main() {
    log_info "======================================"
    log_info "OpenClaw 工具安装脚本"
    log_info "======================================"

    install_tools
    install_python_packages

    log_info "======================================"
    log_info "工具安装完成"
    log_info "======================================"
}

# 执行主函数
main "$@"