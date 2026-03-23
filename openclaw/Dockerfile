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
ARG OPENCLAW_VERSION=latest

# ============================================
# 阶段 1: 前端构建
# ============================================
FROM oven/bun:latest AS frontend-builder

WORKDIR /build

# 克隆 OpenClaw 仓库 main 分支
RUN git clone --depth 1 --branch ${OPENCLAW_VERSION} https://github.com/openclaw/openclaw.git . && \
    cd web && \
    bun install && \
    bun run build

# ============================================
# 阶段 2: 后端构建
# ============================================
FROM golang:alpine AS backend-builder

ENV GO111MODULE=on CGO_ENABLED=0
ENV GOEXPERIMENT=greenteagc

WORKDIR /build

# 克隆 OpenClaw 仓库 main 分支
RUN apk add --no-cache git && \
    git clone --depth 1 --branch ${OPENCLAW_VERSION} https://github.com/openclaw/openclaw.git . && \
    go mod download

# 复制前端构建产物
COPY --from=frontend-builder /build/dist ./web/dist

# 构建后端
RUN go build -ldflags "-s -w -X 'github.com/openclaw/openclaw/common.Version=$(cat VERSION)'" -o new-api

# ============================================
# 阶段 3: 运行时镜像
# ============================================
FROM debian:bookworm-slim AS runtime

# 安装基础工具和依赖
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        tzdata \
        curl \
        wget \
        vim \
        procps \
        python3 \
        python3-pip \
        python3-venv \
        ffmpeg \
        git \
        openssh-client \
        && rm -rf /var/lib/apt/lists/* \
        && update-ca-certificates

# 复制构建产物
COPY --from=backend-builder /build/new-api /usr/local/bin/openclaw

# 创建必要的目录
RUN mkdir -p /data /var/log/openclaw && \
    chmod 755 /data /var/log/openclaw

# 设置环境变量
ENV TZ=UTC
ENV SESSION_SECRET=random_session_secret
ENV SQL_DSN=""

# 暴露端口
EXPOSE 3000

# 健康检查
HEALTHCHECK --interval=3m --timeout=10s --start-period=15s --retries=3 \
    CMD curl -f http://127.0.0.1:18789/healthz || exit 1

# 创建非 root 用户
RUN useradd -r -s /bin/false -u 1000 openclaw && \
    chown -R openclaw:openclaw /data /var/log/openclaw

USER openclaw

WORKDIR /data

CMD ["/usr/local/bin/openclaw", "gateway", "--allow-unconfigured"]