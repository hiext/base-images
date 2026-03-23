# syntax=docker/dockerfile:1.7
#
# new-api Docker Image - AI Model Gateway
#
# 基于 Debian Bookworm，预装调试工具，支持多架构
#
# 构建示例:
#   docker build -t new-api:latest .
#   docker build --build-arg NEW_API_VERSION=v0.5.0 -t new-api:v0.5.0 .
#
# 运行示例:
#   docker run -d -p 3000:3000 new-api:latest
#

# ============================================
# 构建参数定义
# ============================================
ARG NEW_API_VERSION=latest

# ============================================
# 阶段 1: 前端构建
# ============================================
FROM oven/bun:latest AS frontend-builder

WORKDIR /build

# 克隆 new-api 仓库
ARG NEW_API_VERSION
RUN apt-get update && apt-get install -y git && \
    if [ "$NEW_API_VERSION" = "latest" ]; then \
        git clone --depth 1 https://github.com/QuantumNous/new-api.git .; \
    else \
        git clone --depth 1 --branch ${NEW_API_VERSION} https://github.com/QuantumNous/new-api.git .; \
    fi

# 构建前端
WORKDIR /build/web
RUN bun install && \
    DISABLE_ESLINT_PLUGIN='true' VITE_REACT_APP_VERSION=$(cat ../VERSION) bun run build

# ============================================
# 阶段 2: 后端构建
# ============================================
FROM golang:alpine AS backend-builder

ENV GO111MODULE=on CGO_ENABLED=0
ENV GOEXPERIMENT=greenteagc

WORKDIR /build

# 克隆 new-api 仓库
ARG NEW_API_VERSION
RUN apk add --no-cache git && \
    if [ "$NEW_API_VERSION" = "latest" ]; then \
        git clone --depth 1 https://github.com/QuantumNous/new-api.git .; \
    else \
        git clone --depth 1 --branch ${NEW_API_VERSION} https://github.com/QuantumNous/new-api.git .; \
    fi

# 下载依赖
RUN go mod download

# 复制前端构建产物
COPY --from=frontend-builder /build/dist ./web/dist

# 构建后端
RUN go build -ldflags "-s -w -X 'github.com/QuantumNous/new-api/common.Version=$(cat VERSION)'" -o new-api

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
        && rm -rf /var/lib/apt/lists/* \
        && update-ca-certificates

# 复制构建产物
COPY --from=backend-builder /build/new-api /usr/local/bin/new-api

# 创建必要的目录
RUN mkdir -p /data /var/log/new-api && \
    chmod 755 /data /var/log/new-api

# 复制脚本和配置
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY scripts/healthcheck.sh /usr/local/bin/healthcheck.sh

RUN chmod +x /usr/local/bin/*.sh

# 设置环境变量
ENV TZ=UTC
ENV SESSION_SECRET=random_session_secret
ENV SQL_DSN=""

# 暴露端口
EXPOSE 3000

# 健康检查
HEALTHCHECK --interval=3m --timeout=10s --start-period=15s --retries=3 \
    CMD /usr/local/bin/healthcheck.sh

# 创建非 root 用户
RUN useradd -r -s /bin/false -u 1000 newapi && \
    chown -R newapi:newapi /data /var/log/new-api

USER newapi

WORKDIR /data

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/local/bin/new-api"]