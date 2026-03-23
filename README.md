# Base Images

[![Build and Push Postgres Images](https://github.com/hiext/base-images/actions/workflows/build-postgres.yml/badge.svg)](https://github.com/hiext/base-images/actions/workflows/build-postgres.yml)
[![Build and Push OpenClaw Images](https://github.com/hiext/base-images/actions/workflows/build-openclaw.yml/badge.svg)](https://github.com/hiext/base-images/actions/workflows/build-openclaw.yml)
[![Build and Push new-api Images](https://github.com/hiext/base-images/actions/workflows/build-new-api.yml/badge.svg)](https://github.com/hiext/base-images/actions/workflows/build-new-api.yml)
[![GitHub release](https://img.shields.io/github/v/release/hiext/base-images?include_prereleases)](https://github.com/hiext/base-images/releases)
[![Docker](https://img.shields.io/badge/Platform-linux%2Famd64%20%7C%20linux%2Farm64-blue)](https://hub.docker.com/r/hiext)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

> 🐳 企业级基础 Docker 镜像仓库，提供预配置的高质量容器镜像

---

## 📖 简介

**Base Images** 是一个企业级基础 Docker 镜像仓库，提供预配置、优化和维护的容器镜像。所有镜像都经过严格的测试和验证，支持多架构（amd64/arm64），并通过 GitHub Actions 实现自动化构建和版本管理。

**核心特性**：

- ✅ **生产就绪**：所有镜像都经过测试和验证
- ✅ **多架构支持**：支持 linux/amd64 和 linux/arm64
- ✅ **自动更新**：自动跟踪上游版本，及时更新
- ✅ **安全优化**：非 root 用户运行，最小化攻击面
- ✅ **完整文档**：提供详细的使用文档和部署指南
- ✅ **CI/CD 集成**：GitHub Actions 自动构建和推送

---

## 📦 可用镜像

### PostgreSQL 向量数据库镜像

**镜像地址**：`ghcr.io/hiext/postgres`

专为 AI 和机器学习应用优化的 PostgreSQL 镜像，集成向量搜索扩展。

**特性**：
- ✅ 集成 pgvector、VectorChord、pgvecto.rs 扩展
- ✅ 支持 PostgreSQL 14-18
- ✅ 提供 HDD/SSD 存储优化配置
- ✅ 数据完整性验证

**快速开始**：
```bash
docker pull ghcr.io/hiext/postgres:17-vectorchord0.5.3-pgvector0.8.1
docker run -d \
  -e POSTGRES_PASSWORD=password \
  -p 5432:5432 \
  ghcr.io/hiext/postgres:17-vectorchord0.5.3-pgvector0.8.1
```

**详细文档**：[postgres/README.md](./postgres/README.md)

---

### OpenClaw AI 助手镜像

**镜像地址**：`ghcr.io/hiext/openclaw`

个人 AI 助手平台，支持多种消息渠道，预装多媒体处理工具。

**特性**：
- ✅ 支持多种消息渠道（WhatsApp、Telegram、Slack 等）
- ✅ 预装 Python 3、FFmpeg、FFprobe
- ✅ 多基础镜像支持（Ubuntu、Debian）
- ✅ 自动版本跟踪

**快速开始**：
```bash
docker pull ghcr.io/hiext/openclaw:latest
docker run -d \
  -p 18789:18789 \
  -e GATEWAY_BIND=0.0.0.0 \
  ghcr.io/hiext/openclaw:latest
```

**详细文档**：[openclaw/README.md](./openclaw/README.md)

---

### new-api AI 模型网关镜像

**镜像地址**：`ghcr.io/hiext/new-api`

统一的 AI 模型聚合和分发中心，支持多种 LLM API 转换。

**特性**：
- ✅ 支持 OpenAI、Claude、Gemini 等多种 LLM
- ✅ 模型格式转换（OpenAI/Claude/Gemini 兼容）
- ✅ API 网关功能
- ✅ 自动版本跟踪

**快速开始**：
```bash
docker pull ghcr.io/hiext/new-api:latest
docker run -d \
  -p 3000:3000 \
  -e SESSION_SECRET=your_secret_key \
  ghcr.io/hiext/new-api:latest
```

**详细文档**：[new-api/README.md](./new-api/README.md)

---

## 🚀 快速开始

### 1. 选择镜像

根据您的需求选择合适的镜像：

| 用途 | 推荐镜像 | 说明 |
|-----|---------|------|
| AI/ML 向量搜索 | `ghcr.io/hiext/postgres` | PostgreSQL + 向量扩展 |
| 个人 AI 助手 | `ghcr.io/hiext/openclaw` | OpenClaw + 多媒体工具 |
| AI 模型网关 | `ghcr.io/hiext/new-api` | 多 LLM 聚合网关 |

### 2. 拉取镜像

```bash
# PostgreSQL 向量数据库
docker pull ghcr.io/hiext/postgres:latest

# OpenClaw AI 助手
docker pull ghcr.io/hiext/openclaw:latest

# new-api AI 模型网关
docker pull ghcr.io/hiext/new-api:latest
```

### 3. 运行容器

**PostgreSQL 示例**：
```bash
docker run -d \
  --name postgres-vector \
  -e POSTGRES_PASSWORD=password \
  -e DB_STORAGE_TYPE=SSD \
  -p 5432:5432 \
  ghcr.io/hiext/postgres:latest
```

**OpenClaw 示例**：
```bash
docker run -d \
  --name openclaw \
  -p 18789:18789 \
  -e GATEWAY_BIND=0.0.0.0 \
  -v $(pwd)/data:/app/data \
  ghcr.io/hiext/openclaw:latest
```

### 4. 验证运行

```bash
# 检查容器状态
docker ps

# 查看日志
docker logs -f <container-name>

# 健康检查
docker exec <container-name> healthcheck.sh
```

---

## 📚 文档

### PostgreSQL 模块

- 📖 [模块 README](./postgres/README.md) - 快速开始和基本信息
- 🤖 [CLAUDE.md](./postgres/CLAUDE.md) - AI 上下文文档
- ⚙️ [配置文件](./postgres/config/) - PostgreSQL 配置模板

### OpenClaw 模块

- 📖 [模块 README](./openclaw/README.md) - 快速开始和基本信息
- 🚀 [部署指南](./openclaw/DEPLOYMENT.md) - 完整部署和使用说明
- ⚡ [快速参考](./openclaw/QUICK_REFERENCE.md) - 一页纸速查手册
- 🔄 [CI/CD 指南](./openclaw/CICD_GUIDE.md) - GitHub Actions 工作流详解
- 🤖 [CLAUDE.md](./openclaw/CLAUDE.md) - AI 上下文文档

### 项目文档

- 🤖 [根级 CLAUDE.md](./CLAUDE.md) - 项目总览和模块索引

---

## 🏗️ 项目结构

```
base-images/
├── postgres/                    # PostgreSQL 模块
│   ├── Dockerfile              # 主构建文件
│   ├── versions.yaml           # 版本矩阵
│   ├── docker-compose.yml      # 本地开发配置
│   ├── scripts/                # 脚本文件
│   │   ├── entrypoint.sh
│   │   └── healthcheck.sh
│   ├── config/                 # 配置文件
│   │   ├── postgresql.ssd.conf
│   │   └── postgresql.hdd.conf
│   ├── README.md               # 模块文档
│   └── CLAUDE.md               # AI 上下文
│
├── openclaw/                    # OpenClaw 模块
│   ├── Dockerfile              # 通用 Dockerfile
│   ├── versions.yaml           # 版本配置
│   ├── docker-compose.yml      # 本地开发配置
│   ├── scripts/                # 脚本文件
│   │   ├── entrypoint.sh
│   │   ├── healthcheck.sh
│   │   ├── download-latest.sh
│   │   └── install-tools.sh
│   ├── config/                 # 配置文件
│   │   └── openclaw.default.conf
│   ├── README.md               # 模块文档
│   ├── DEPLOYMENT.md           # 部署指南
│   ├── QUICK_REFERENCE.md      # 快速参考
│   ├── CICD_GUIDE.md           # CI/CD 说明
│   └── CLAUDE.md               # AI 上下文
│
├── .github/                     # GitHub 配置
│   └── workflows/              # CI/CD 工作流
│       ├── build-postgres.yml
│       └── build-openclaw.yml
│
├── CLAUDE.md                    # 项目总览文档
└── README.md                    # 本文件
```

---

## 🛠️ 本地开发

### 克隆仓库

```bash
git clone https://github.com/hiext/base-images.git
cd base-images
```

### 构建镜像

**PostgreSQL**：
```bash
cd postgres
docker build -t postgres-vector:local .
```

**OpenClaw**：
```bash
cd openclaw
docker build -t openclaw:local .
```

### 使用 Docker Compose

```bash
# PostgreSQL
cd postgres
docker-compose up -d

# OpenClaw
cd openclaw
docker-compose up -d
```

---

## 🔄 CI/CD 自动化

本项目使用 GitHub Actions 实现自动化构建和发布：

### 自动触发

- ✅ **推送触发**：推送到 `main` 分支时自动构建
- ✅ **定时构建**：定期检查上游版本更新
- ✅ **PR 测试**：Pull Request 时进行构建测试（不推送镜像）

### 手动触发

```bash
# 使用 GitHub CLI
gh workflow run build-postgres.yml
gh workflow run build-openclaw.yml

# 或通过 Web UI
# Actions → 选择工作流 → Run workflow
```

### 构建状态

查看实时构建状态：
- [PostgreSQL 构建状态](https://github.com/hiext/base-images/actions/workflows/build-postgres.yml)
- [OpenClaw 构建状态](https://github.com/hiext/base-images/actions/workflows/build-openclaw.yml)

---

## 📊 镜像标签策略

### PostgreSQL

| 标签格式 | 示例 | 说明 |
|---------|------|------|
| `{pg}-vectorchord{vc}-pgvector{pv}` | `17-vectorchord0.5.3-pgvector0.8.1` | 完整版本标签 |
| `{pg}-vectorchord{vc}` | `17-vectorchord0.5.3` | 简化版本（最新 pgvector） |

### OpenClaw

| 标签格式 | 示例 | 说明 |
|---------|------|------|
| `{version}` | `2026.3.13` | 指定版本（Ubuntu 24.04） |
| `latest` | `latest` | 最新版本（Ubuntu 24.04） |
| `{version}-ubuntu22` | `2026.3.13-ubuntu22` | Ubuntu 22.04 变体 |
| `{version}-debian` | `2026.3.13-debian` | Debian Bookworm 变体 |

---

## 🐛 故障排查

### 常见问题

#### 1. 镜像拉取失败

```bash
# 登录 GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

# 拉取镜像
docker pull ghcr.io/hiext/postgres:latest
```

#### 2. 容器无法启动

```bash
# 查看日志
docker logs <container-name>

# 检查端口冲突
netstat -tlnp | grep <port>

# 进入容器调试
docker exec -it <container-name> /bin/bash
```

#### 3. 权限问题

```bash
# 使用 root 用户运行
docker run --user root <image-name>

# 修复数据目录权限
docker exec <container-name> chown -R <user>:<group> /app/data
```

### 获取帮助

- 📖 查看模块文档（postgres/README.md 或 openclaw/README.md）
- 🐛 [提交 Issue](https://github.com/hiext/base-images/issues)
- 💬 [讨论区](https://github.com/hiext/base-images/discussions)

---

## 🤝 贡献

我们欢迎任何形式的贡献！

### 贡献方式

1. **报告问题**：提交 Bug 报告或功能建议
2. **提交代码**：修复 Bug 或添加新功能
3. **改进文档**：完善文档或翻译
4. **分享经验**：分享使用案例和最佳实践

### 开发流程

```bash
# 1. Fork 本仓库
# 2. 创建特性分支
git checkout -b feature/amazing-feature

# 3. 提交更改
git commit -m 'feat: add amazing feature'

# 4. 推送到分支
git push origin feature/amazing-feature

# 5. 创建 Pull Request
```

### 代码规范

- Shell 脚本：使用 `#!/usr/bin/env bash` 和 `set -eo pipefail`
- Dockerfile：多阶段构建，清理缓存
- 提交信息：遵循 [Conventional Commits](https://www.conventionalcommits.org/)

---

## 📄 许可证

本项目采用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

各模块依赖的第三方软件遵循其各自的许可证：

- PostgreSQL：[PostgreSQL License](https://www.postgresql.org/about/licence/)
- OpenClaw：[MIT License](https://github.com/openclaw/openclaw/blob/main/LICENSE)
- pgvector：[PostgreSQL License](https://github.com/pgvector/pgvector/blob/master/LICENSE)
- VectorChord：[Apache 2.0](https://github.com/tensorchord/VectorChord/blob/main/LICENSE)

---

## 🙏 致谢

感谢以下项目和组织的支持：

- [PostgreSQL](https://www.postgresql.org/) - 强大的开源数据库
- [pgvector](https://github.com/pgvector/pgvector) - PostgreSQL 向量扩展
- [VectorChord](https://github.com/tensorchord/VectorChord) - 高性能向量索引
- [OpenClaw](https://openclaw.ai/) - 个人 AI 助手平台
- [GitHub Actions](https://github.com/features/actions) - CI/CD 平台
- [GitHub Container Registry](https://ghcr.io) - 容器镜像托管

---

## 📮 联系方式

- **GitHub**: https://github.com/hiext/base-images
- **Issues**: https://github.com/hiext/base-images/issues
- **Discussions**: https://github.com/hiext/base-images/discussions

---

**⭐ 如果这个项目对您有帮助，请给我们一个 Star！**

---

Made with ❤️ by hiext team