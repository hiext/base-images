# syntax=docker/dockerfile:1.7
#
# OpenClaw Docker Image - Extended with Python and FFmpeg
#
# 基于 OpenClaw 官方镜像，添加 Python、FFmpeg 等工具
#
# 构建示例:
#   docker build -t openclaw:extended .
#
# 运行示例:
#   docker run -d -p 18789:18789 openclaw:extended
#

# ============================================
# 构建参数定义
# ============================================
ARG OPENCLAW_BASE_TAG=latest

# ============================================
# 使用 OpenClaw 官方镜像作为基础
# ============================================
FROM ghcr.io/openclaw/openclaw:${OPENCLAW_BASE_TAG} AS base

USER root

# 安装 Python 和 FFmpeg
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    ffmpeg \
    curl \
    wget \
    vim \
    procps \
    git \
    openssh-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 验证安装
RUN python3 --version && ffmpeg -version

# 创建应用目录
RUN mkdir -p /app/data /app/config /var/log/openclaw \
    && chown -R node:node /app /var/log/openclaw

USER node

WORKDIR /app

# 偵康检查
HEALTHCHECK --interval=3m --timeout=10s --start-period=15s --retries=3 \
    CMD curl -f http://127.0.0.1:18789/healthz || exit 1

CMD ["node", "openclaw.mjs", "gateway", "--allow-unconfigured"]