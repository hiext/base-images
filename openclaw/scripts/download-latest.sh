#!/usr/bin/env bash
#
# OpenClaw 版本自动更新脚本
#
# 功能：
# - 从 GitHub API 获取最新版本
# - 更新 versions.yaml 文件
# - 可在 CI/CD 中自动触发
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

# GitHub API 配置
GITHUB_API="https://api.github.com"
REPO="openclaw/openclaw"

# 函数：从 GitHub API 获取最新版本
get_latest_version() {
    log_info "从 GitHub 获取最新版本..."

    local latest_version
    latest_version=$(curl -s "${GITHUB_API}/repos/${REPO}/releases/latest" | \
        grep '"tag_name":' | \
        sed -E 's/.*"([^"]+)".*/\1/')

    if [[ -z "$latest_version" ]]; then
        log_error "无法获取最新版本"
        exit 1
    fi

    echo "$latest_version"
}

# 函数：提取版本号（去掉 v 前缀）
extract_version() {
    local tag="$1"
    # 去掉 v 前缀，例如 v2026.3.13-1 -> 2026.3.13-1
    echo "${tag#v}"
}

# 函数：更新 versions.yaml
update_versions_file() {
    local version="$1"
    local versions_file="${2:-openclaw/versions.yaml}"

    if [[ ! -f "$versions_file" ]]; then
        log_error "versions.yaml 文件不存在: $versions_file"
        exit 1
    fi

    log_info "更新 versions.yaml: $version"

    # 使用 yq 更新版本号
    if command -v yq > /dev/null 2>&1; then
        yq -i ".openclaw[0] = \"$version\"" "$versions_file"
        log_info "versions.yaml 更新成功"
    else
        log_warn "yq 未安装，跳过自动更新"
        log_info "请手动更新 versions.yaml: openclaw: [\"$version\"]"
    fi
}

# 函数：检查版本是否更新
check_version_change() {
    local new_version="$1"
    local versions_file="${2:-openclaw/versions.yaml}"

    if [[ ! -f "$versions_file" ]]; then
        return 0
    fi

    local current_version
    current_version=$(yq '.openclaw[0]' "$versions_file" 2>/dev/null || echo "unknown")

    if [[ "$current_version" == "$new_version" ]]; then
        log_info "版本未变化: $new_version"
        return 1
    else
        log_info "检测到新版本: $current_version -> $new_version"
        return 0
    fi
}

# 主函数
main() {
    log_info "======================================"
    log_info "OpenClaw 版本检查工具"
    log_info "======================================"

    # 获取最新版本
    local latest_tag
    latest_tag=$(get_latest_version)

    local latest_version
    latest_version=$(extract_version "$latest_tag")

    log_info "最新版本标签: $latest_tag"
    log_info "最新版本号: $latest_version"

    # 检查版本变化
    if check_version_change "$latest_version"; then
        # 更新 versions.yaml
        update_versions_file "$latest_version"

        # 输出版本号供 CI 使用
        echo "::set-output name=version::$latest_version"
        echo "::set-output name=changed::true"

        log_info "版本更新完成"
        exit 0
    else
        echo "::set-output name=changed::false"
        log_info "无需更新"
        exit 0
    fi
}

# 执行主函数
main "$@"