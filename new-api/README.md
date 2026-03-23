# new-api Docker 镜像

[![Build and Push new-api Images](https://github.com/hiext/base-images/actions/workflows/build-new-api.yml/badge.svg)](https://github.com/hiext/base-images/actions/workflows/build-new-api.yml)
[![new-api](https://img.shields.io/badge/new-api-latest-blue)](https://github.com/QuantumNous/new-api)
[![Docker](https://img.shields.io/badge/Docker-Debian%20Bookworm-blue)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-AGPL%203.0-green)](LICENSE)

> 🍥 自定义 new-api Docker 镜像，AI 模型聚合网关，支持多架构

## 📖 简介

本项目提供预配置的 new-api Docker 镜像，专为 AI 模型聚合和分发优化。

**主要特性**：

- ✅ **自动版本跟踪**：自动获取并构建最新版本
- ✅ **多架构支持**：linux/amd64、linux/arm64
- ✅ **生产就绪**：健康检查、非 root 用户、安全配置
- ✅ **预装工具**：curl、wget、vim 等调试工具
- ✅ **数据持久化**：支持数据卷挂载

## 🚀 快速开始

### 拉取镜像

```bash
# 从 GitHub Container Registry 拉取
docker pull ghcr.io/hiext/new-api:latest
```

### 运行容器

```bash
# 基本运行
docker run -d \
  --name new-api \
  -p 3000:3000 \
  ghcr.io/hiext/new-api:latest

# 使用环境变量配置
docker run -d \
  --name new-api \
  -p 3000:3000 \
  -e TZ=Asia/Shanghai \
  -e SESSION_SECRET=your_secret_key \
  -v $(pwd)/data:/data \
  ghcr.io/hiext/new-api:latest
```

### 使用 Docker Compose

```bash
# 克隆仓库
git clone https://github.com/hiext/base-images.git
cd base-images/new-api

# 启动服务
docker-compose up -d

# 查看日志
docker-compose logs -f new-api
```

## 📦 可用镜像标签

| 标签 | 说明 |
|------|------|
| `latest` | 最新版本 |
| `v0.5.0` | 指定版本 |

## 🔧 配置

### 环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `PORT` | `3000` | 监听端口 |
| `TZ` | `UTC` | 时区设置 |
| `SESSION_SECRET` | `random_session_secret` | 会话密钥 |
| `SQL_DSN` | - | 数据库连接字符串（可选） |

### 数据持久化

```bash
docker run -d \
  --name new-api \
  -v $(pwd)/data:/data \
  -v $(pwd)/logs:/var/log/new-api \
  ghcr.io/hiext/new-api:latest
```

## 🛠️ 本地构建

### 构建镜像

```bash
# 默认构建
docker build -t new-api:local .

# 指定版本构建
docker build --build-arg NEW_API_VERSION=v0.5.0 -t new-api:v0.5.0 .
```

## 🔍 健康检查

容器内置健康检查机制：

```bash
# 手动健康检查
docker exec new-api /usr/local/bin/healthcheck.sh

# 或通过 HTTP 端点
curl http://localhost:3000/api/status
```

## 📚 使用示例

### 验证运行状态

```bash
# 检查容器状态
docker ps | grep new-api

# 查看日志
docker logs -f new-api

# 进入容器
docker exec -it new-api /bin/bash
```

### 配置 AI 模型网关

1. **访问 Web UI**：http://localhost:3000
2. **配置 API 密钥**：在设置中添加您的 AI 模型 API 密钥
3. **创建渠道**：配置不同的 AI 模型渠道（OpenAI、Claude、Gemini 等）
4. **测试连接**：验证模型连接是否正常

## 🐛 故障排查

### 容器无法启动

```bash
# 查看日志
docker logs new-api

# 检查端口冲突
netstat -tlnp | grep 3000

# 检查权限
docker run --user root new-api:latest
```

### 端口访问问题

确保端口正确映射：

```bash
docker run -d -p 3000:3000 ghcr.io/hiext/new-api:latest
```

### 数据持久化问题

确保数据目录权限正确：

```bash
docker exec new-api ls -la /data
```

## 📖 相关链接

- [new-api 官方仓库](https://github.com/QuantumNous/new-api)
- [new-api 官方文档](https://github.com/QuantumNous/new-api#readme)
- [GitHub 仓库](https://github.com/hiext/base-images)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

本项目的 Dockerfile 和配置文件采用 MIT 许可证。

new-api 本身采用 AGPL-3.0 许可证，详见 [new-api License](https://github.com/QuantumNous/new-api/blob/main/LICENSE)。