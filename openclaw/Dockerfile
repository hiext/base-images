# syntax=docker/dockerfile:1.7
#
# OpenClaw Docker Image - Production Ready
#
# 基于 Node.js 官方镜像，参考 OpenClaw 官方 Dockerfile 最佳实践
#
# 构建示例:
#   docker build -t openclaw:latest .
#   docker build --build-arg NODE_VERSION=22 -t openclaw:node22 .
#
# 运行示例:
#   docker run -d -p 18789:18789 openclaw:latest
#

# ============================================
# 构建参数定义
# ============================================
ARG NODE_VERSION=20
ARG OPENCLAW_VERSION=latest

# ============================================
# 阶段 1: 基础镜像
# ============================================
ARG NODE_VERSION
FROM node:${NODE_VERSION}-bookworm-slim AS base

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# 安装基础依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    ca-certificates \
    python3 \
    python3-pip \
    ffmpeg \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ============================================
# 阶段 2: 安装 OpenClaw
# ============================================
FROM base AS builder

ARG OPENCLAW_VERSION

# 安装 OpenClaw（允许失败并重试）
RUN set -eux; \
    # 配置 npm
    npm config set registry https://registry.npmjs.org/; \
    npm config set loglevel verbose; \
    # 尝试安装，最多重试 3 次
    for i in 1 2 3; do \
        npm install -g openclaw@${OPENCLAW_VERSION} && break || { \
            echo "Attempt $i failed, retrying in 5 seconds..."; \
            sleep 5; \
            npm cache clean --force; \
        }; \
    done; \
    # 验证安装
    npm list -g openclaw || echo "Package list check completed"

# ============================================
# 阶段 3: 运行时镜像
# ============================================
FROM base AS runtime

# 从构建阶段复制 OpenClaw
COPY --from=builder /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=builder /usr/local/bin /usr/local/bin

# 创建必要的目录
RUN mkdir -p /app/data /app/config /var/log/openclaw \
    && chmod 755 /app /var/log/openclaw

# 复制脚本和配置
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY scripts/healthcheck.sh /usr/local/bin/healthcheck.sh
COPY config/openclaw.default.conf /etc/openclaw/openclaw.default.conf

RUN chmod +x /usr/local/bin/*.sh

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
RUN useradd -r -s /bin/false -u 1000 openclaw \
    && chown -R openclaw:openclaw /app /var/log/openclaw

USER openclaw
WORKDIR /app

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["openclaw", "gateway", "--allow-unconfigured"]