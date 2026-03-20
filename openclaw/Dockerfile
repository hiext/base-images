# syntax=docker/dockerfile:1.7
#
# OpenClaw Docker Image - Universal Multi-Base Image Support
#
# 支持 Ubuntu 24.04/22.04 和 Debian Bookworm 的通用 Dockerfile
# 通过构建参数动态选择基础镜像和 Node.js 版本
#
# 构建示例:
#   # 默认构建（Ubuntu 24.04 + Node.js 24）
#   docker build -t openclaw:latest .
#
#   # Ubuntu 22.04 变体（Node.js 22）
#   docker build --build-arg BASE_IMAGE=ubuntu:22.04 --build-arg NODE_VERSION=22 -t openclaw:ubuntu22 .
#
#   # Debian Bookworm 变体
#   docker build --build-arg BASE_IMAGE=debian:bookworm -t openclaw:debian .
#
# 运行示例:
#   docker run -d -p 18789:18789 openclaw:latest
#

# ============================================
# 构建参数定义
# ============================================
# 基础镜像（支持 ubuntu:24.04, ubuntu:22.04, debian:bookworm）
ARG BASE_IMAGE=ubuntu:24.04
# Node.js 版本（Ubuntu 24.04/Debian 默认 24，Ubuntu 22.04 使用 22）
ARG NODE_VERSION=24
# OpenClaw 版本
ARG OPENCLAW_VERSION=latest

# ============================================
# 阶段 1: 基础镜像
# ============================================
FROM ${BASE_IMAGE} AS base

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# ============================================
# 阶段 2: 安装系统依赖和工具
# ============================================
FROM base AS deps

# 安装系统依赖、Python、FFmpeg
# 注意：Debian 和 Ubuntu 的包名可能略有不同
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        # 基础工具
        curl \
        wget \
        gnupg \
        ca-certificates \
        # Python 3
        python3 \
        python3-pip \
        python3-venv \
        # FFmpeg 和 FFprobe
        ffmpeg \
        # 构建工具（某些 npm 包可能需要）
        build-essential \
        # 其他实用工具
        git \
        vim \
        procps \
        ; \
    # 清理缓存
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    # 验证安装
    python3 --version; \
    ffmpeg -version; \
    ffprobe -version

# ============================================
# 阶段 3: 安装 Node.js
# ============================================
FROM deps AS nodejs

# 重新声明 ARG（多阶段构建需要）
ARG NODE_VERSION

# 安装 Node.js
RUN set -eux; \
    # 添加 NodeSource 仓库
    curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash -; \
    # 安装 Node.js
    apt-get install -y --no-install-recommends nodejs; \
    # 清理缓存
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    # 验证安装
    node --version; \
    npm --version; \
    # 配置 npm（避免权限问题）
    npm config set unsafe-perm true

# ============================================
# 阶段 4: 安装 OpenClaw
# ============================================
FROM nodejs AS openclaw

# 重新声明 ARG
ARG OPENCLAW_VERSION

# 全局安装 OpenClaw
# 使用 unsafe-perm 避免权限问题
RUN set -eux; \
    npm install -g --unsafe-perm openclaw@${OPENCLAW_VERSION}; \
    # 验证安装（某些情况下 --version 可能失败，但包已安装）
    openclaw --version || echo "OpenClaw ${OPENCLAW_VERSION} installed"; \
    # 确保 openclaw 可执行
    which openclaw || npm bin -g

# ============================================
# 阶段 5: 配置和脚本
# ============================================
FROM openclaw AS runtime

# 创建必要的目录
RUN set -eux; \
    mkdir -p /app/data /app/config /var/log/openclaw; \
    chmod 755 /app /var/log/openclaw

# 复制脚本文件
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY scripts/healthcheck.sh /usr/local/bin/healthcheck.sh
COPY scripts/install-tools.sh /usr/local/bin/install-tools.sh

# 复制配置文件
COPY config/openclaw.default.conf /etc/openclaw/openclaw.default.conf

# 设置脚本权限
RUN set -eux; \
    chmod +x /usr/local/bin/entrypoint.sh; \
    chmod +x /usr/local/bin/healthcheck.sh; \
    chmod +x /usr/local/bin/install-tools.sh

# 设置环境变量
ENV NODE_ENV=production
ENV OPENCLAW_PORT=18789
ENV OPENCLAW_BIND=127.0.0.1

# 暴露端口
EXPOSE 18789

# 健康检查
HEALTHCHECK --interval=3m --timeout=10s --start-period=15s --retries=3 \
    CMD /usr/local/bin/healthcheck.sh

# 创建非 root 用户
RUN set -eux; \
    useradd -r -s /bin/false -u 1000 openclaw; \
    chown -R openclaw:openclaw /app /var/log/openclaw

# 切换到非 root 用户
USER openclaw

# 工作目录
WORKDIR /app

# 入口点
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# 默认命令：启动 OpenClaw Gateway
CMD ["openclaw", "gateway", "--allow-unconfigured"]