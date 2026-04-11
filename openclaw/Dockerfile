# syntax=docker/dockerfile:1.7
#
# OpenClaw Docker Image - Extended with Python and FFmpeg
#
# 基于 OpenClaw 官方镜像，添加 Python、FFmpeg、国内镜像源等工具
#
# 构建示例:
# docker build -t openclaw:extended .
#
# 运行示例:
# docker run -d -p 18789:18789 openclaw:extended
#

# ============================================
# 基础镜像参数
# ============================================
ARG BASE_IMAGE=ubuntu:24.04
ARG NODE_VERSION=24
ARG OPENCLAW_BASE_TAG=latest

# ============================================
# 基础镜像安装阶段
# ============================================
FROM ${BASE_IMAGE} AS base-builder

ARG NODE_VERSION
ARG TARGETARCH

# 安装基础工具
RUN apt-get update && apt-get install -y --no-install-recommends \
 curl \
 wget \
 ca-certificates \
 gnupg \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# 安装 Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
 && apt-get install -y nodejs \
 && npm install -g npm@latest \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# ============================================
# 使用 OpenClaw 官方镜像作为基础
# ============================================
FROM ghcr.io/openclaw/openclaw:${OPENCLAW_BASE_TAG} AS openclaw-base

USER root

# ============================================
# 最终镜像构建
# ============================================
FROM openclaw-base AS final

USER root

# 安装 Python、FFmpeg 和常用工具
RUN apt-get update && apt-get install -y --no-install-recommends \
 python3 \
 python3-pip \
 python3-venv \
 ffmpeg \
 curl \
 wget \
 jq \
 vim \
 procps \
 git \
 openssh-client \
 ca-certificates \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# 配置 pip 使用清华大学 TUNA 镜像源
RUN pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple && \
 pip3 config set install.trusted-host pypi.tuna.tsinghua.edu.cn

# 创建应用目录
RUN mkdir -p /app/data /app/config /var/log/openclaw \
 && chown -R node:node /app /var/log/openclaw

# 切换到 node 用户配置 npm
USER node

# 配置 npm 使用淘宝镜像源
RUN npm config set registry https://registry.npmmirror.com

# 验证安装
USER root
RUN python3 --version && pip3 --version && ffmpeg -version

USER node

WORKDIR /app

# 健康检查
HEALTHCHECK --interval=3m --timeout=10s --start-period=15s --retries=3 \
 CMD curl -f http://127.0.0.1:18789/healthz || exit 1

CMD ["node", "openclaw.mjs", "gateway", "--allow-unconfigured"]
