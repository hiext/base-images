#!/usr/bin/env bash
#
# OpenClaw 健康检查脚本
#
# 功能：
# - 检查 OpenClaw Gateway 健康状态
# - 返回适当的退出码
#

set -eo pipefail

# 配置
HEALTH_ENDPOINT="${OPENCLAW_HEALTH_ENDPOINT:-http://localhost:18789/healthz}"
TIMEOUT="${HEALTHCHECK_TIMEOUT:-10}"

# 执行健康检查
check_health() {
    # 使用 curl 检查健康端点
    if curl -f -s -m "$TIMEOUT" "$HEALTH_ENDPOINT" > /dev/null 2>&1; then
        exit 0
    else
        exit 1
    fi
}

# 执行检查
check_health