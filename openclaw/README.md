# OpenClaw Docker 镜像

[![Build and Push OpenClaw Images](https://github.com/hiext/base-images/actions/workflows/build-openclaw.yml/badge.svg)](https://github.com/hiext/base-images/workflows/build-openclaw.yml)
[![OpenClaw](https://img.shields.io/badge/OpenClaw-latest-blue)](https://github.com/openclaw/openclaw)
[![Docker](https://img.shields.io/badge/Docker-24.04%20%7C%2022.04%20%7C%20Debian-blue)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

> 🦞 基于 [OpenClaw 官方镜像](https://github.com/openclaw/openclaw) 扩展构建，预装 Python、FFmpeg 等常用工具

## 📋 镜像关系

```
┌─────────────────────────────────────────────────────────┐
│  ghcr.io/openclaw/openclaw:latest                        │
│  ↳ OpenClaw 官方纯净镜像                                  │
│  ↳ Node.js + OpenClaw Gateway                             │
└────────────────────┬────────────────────────────────────┘
                     │ 基于官方镜像扩展
                     ▼
┌─────────────────────────────────────────────────────────┐
│  ghcr.io/hiext/openclaw:latest                           │
│  ↳ **本仓库构建的扩展镜像**                                │
│  ↳ 官方镜像 + Python 3.11 + FFmpeg + Git + 常用工具       │
└─────────────────────────────────────────────────────────┘
```

**使用本镜像的优势**：
- ✅ 完全兼容官方功能
- ✅ 预装 AI 工作流常用工具
- ✅ 无需每次手动安装依赖
- ✅ 与官方版本同步更新

## 📖 简介

本项目提供预配置的 OpenClaw Docker 镜像，专为个人 AI 助手部署优化。

**主要特性**：

- ✅ **多基础镜像支持**：Ubuntu 24.04/22.04、Debian Bookworm
- ✅ **预装工具**：Python 3、FFmpeg、FFprobe
- ✅ **自动版本跟踪**：自动获取并构建最新版本
- ✅ **多架构支持**：linux/amd64、linux/arm64
- ✅ **生产就绪**：健康检查、非 root 用户、安全配置

**📚 完整文档**：

- 🚀 [部署和使用指南](./DEPLOYMENT.md) - 完整的部署、测试和使用说明
- ⚡ [快速参考卡](./QUICK_REFERENCE.md) - 一页纸快速查询指南
- 🔄 [CI/CD 工作流说明](./CICD_GUIDE.md) - GitHub Actions 自动化详解
- 🤖 [AI 上下文文档](./CLAUDE.md) - 模块技术文档

## 🚀 快速开始

### 方式一：使用 Docker Compose（推荐）

```bash
# 1. 下载配置
curl -O https://raw.githubusercontent.com/hiext/base-images/main/openclaw/docker-compose.user.yml
mv docker-compose.user.yml docker-compose.yml

# 2. 创建数据目录
mkdir -p data config logs

# 3. 启动
docker compose up -d

# 4. 验证
docker compose ps
curl http://localhost:18789/healthz
```

### 方式二：直接拉取镜像

```bash
# 从 GitHub Container Registry 拉取
docker pull ghcr.io/hiext/openclaw:latest

# 或指定基础镜像变体
docker pull ghcr.io/hiext/openclaw:latest-ubuntu22
docker pull ghcr.io/hiext/openclaw:latest-debian
```

### 运行容器

```bash
# 基本运行
docker run -d \
  --name openclaw \
  -p 18789:18789 \
  ghcr.io/hiext/openclaw:latest

# 使用环境变量配置
docker run -d \
  --name openclaw \
  -p 18789:18789 \
  -e OPENCLAW_TZ=Asia/Shanghai \
  -e GATEWAY_BIND=0.0.0.0 \
  -v $(pwd)/data:/app/data \
  ghcr.io/hiext/openclaw:latest
```

### 使用 Docker Compose（完整版）

```bash
# 克隆仓库（本地构建）
git clone https://github.com/hiext/base-images.git
cd base-images/openclaw

# 本地构建并启动
docker compose -f docker-compose.yml up -d --build

# 或使用预构建镜像（更快）
docker compose -f docker-compose.user.yml up -d

# 查看日志
docker compose logs -f openclaw
```

## 📦 可用镜像标签

| 标签 | 基础镜像 | 说明 |
|------|---------|------|
| `latest` | Ubuntu 24.04 | 推荐使用，最新功能 |
| `latest-ubuntu22` | Ubuntu 22.04 LTS | 长期支持版本 |
| `latest-debian` | Debian 12 Bookworm | 稳定性优先 |
| `2026.3.13` | Ubuntu 24.04 | 指定版本 |
| `2026.3.13-ubuntu22` | Ubuntu 22.04 | 指定版本 + 基础镜像 |

## 🔧 配置

### 环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `GATEWAY_PORT` | `18789` | Gateway 端口 |
| `GATEWAY_BIND` | `127.0.0.1` | 绑定地址 |
| `OPENCLAW_TZ` | `UTC` | 时区设置 |
| `NODE_ENV` | `production` | 运行环境 |
| `LOG_LEVEL` | `info` | 日志级别 |

### 数据持久化

```bash
docker run -d \
  --name openclaw \
  -v $(pwd)/data:/app/data \
  -v $(pwd)/config:/app/config \
  -v $(pwd)/logs:/var/log/openclaw \
  ghcr.io/hiext/openclaw:latest
```

## 🛠️ 本地构建

### 构建镜像

```bash
# 默认构建（Ubuntu 24.04 + Node.js 24）
docker build -t openclaw:local .

# 构建 Ubuntu 22.04 变体（Node.js 22）
docker build --build-arg BASE_IMAGE=ubuntu:22.04 --build-arg NODE_VERSION=22 -t openclaw:ubuntu22 .

# 构建 Debian Bookworm 变体
docker build --build-arg BASE_IMAGE=debian:bookworm -t openclaw:debian .

# 指定 OpenClaw 版本
docker build --build-arg OPENCLAW_VERSION=2026.3.13 -t openclaw:2026.3.13 .
```

### 自定义构建

```bash
# 安装额外工具
docker run --rm openclaw:local /usr/local/bin/install-tools.sh
```

## 🔍 健康检查

容器内置健康检查机制：

```bash
# 手动健康检查
docker exec openclaw /usr/local/bin/healthcheck.sh

# 或通过 HTTP 端点
curl http://localhost:18789/healthz
```

## 📚 使用示例

### 验证预装工具

```bash
# 检查 Python
docker run --rm openclaw:local python3 --version

# 检查 FFmpeg
docker run --rm openclaw:local ffmpeg -version

# 检查 OpenClaw
docker run --rm openclaw:local openclaw --version
```

### 运行 OpenClaw 命令

```bash
# 启动 Gateway
docker run -d -p 18789:18789 openclaw:local

# 发送消息
docker exec openclaw openclaw message send --to +1234567890 --message "Hello"

# 与助手对话
docker exec -it openclaw openclaw agent --message "Ship checklist"
```

## 🐛 故障排查

### 容器无法启动

```bash
# 查看日志
docker logs openclaw

# 进入容器调试
docker run -it --rm openclaw:local /bin/bash
```

### 端口访问问题

如果使用 Docker bridge 网络，需要修改绑定地址：

```bash
docker run -d \
  -p 18789:18789 \
  -e GATEWAY_BIND=0.0.0.0 \
  openclaw:local
```

### 权限问题

容器默认以非 root 用户运行，如需 root 权限：

```bash
docker run -d --user root openclaw:local
```

## 📖 相关链接

- [OpenClaw 官方文档](https://docs.openclaw.ai)
- [OpenClaw GitHub](https://github.com/openclaw/openclaw)
- [Docker Hub](https://hub.docker.com/r/hiext/openclaw)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

本项目的 Dockerfile 和配置文件采用 MIT 许可证。

OpenClaw 本身也采用 MIT 许可证，详见 [OpenClaw License](https://github.com/openclaw/openclaw/blob/main/LICENSE)。