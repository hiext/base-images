[根目录](../CLAUDE.md) > **openclaw**

---

# openclaw 模块文档

> 最后更新：2026-03-19

## 变更记录 (Changelog)

### 2026-03-19
- 初始化 openclaw 模块
- 创建多基础镜像支持（Ubuntu 24.04/22.04、Debian）
- 集成 Python、FFmpeg、FFprobe
- 配置 GitHub Actions 自动构建

---

## 模块职责

openclaw 模块负责构建自定义的 OpenClaw Docker 镜像，为个人 AI 助手部署提供完整的运行环境。主要功能包括：

1. 提供多基础镜像变体（Ubuntu、Debian）
2. 预装 Python 3、FFmpeg、FFprobe 等工具
3. 自动跟踪 OpenClaw 最新版本
4. 提供健康检查和配置管理
5. 支持多架构（amd64/arm64）

---

## 入口与启动

### Dockerfile 构建入口

**主构建文件**：`Dockerfile`
**变体构建文件**：
- `Dockerfile.ubuntu22` - Ubuntu 22.04 变体
- `Dockerfile.debian` - Debian Bookworm 变体

**构建参数**：
- `OPENCLAW_VERSION`：OpenClaw 版本（默认：latest）
- `BASE_IMAGE`：基础镜像（默认：ubuntu:24.04）
- `NODE_VERSION`：Node.js 版本（默认：24）

**基础镜像**：
- Ubuntu 24.04（推荐）
- Ubuntu 22.04 LTS
- Debian 12 (Bookworm)

**入口脚本**：
- `/usr/local/bin/entrypoint.sh`：容器启动入口
- `/usr/local/bin/healthcheck.sh`：健康检查脚本
- `/usr/local/bin/install-tools.sh`：额外工具安装脚本

### docker-compose 本地启动

**文件**：`docker-compose.yml`

**配置要点**：
- 使用非 root 用户运行（openclaw:1000）
- 支持数据持久化（/app/data）
- 可配置时区和环境变量

**启动命令**：
```bash
docker-compose up -d
```

---

## 对外接口

### 环境变量

| 变量名 | 描述 | 示例值 |
|-------|------|--------|
| `GATEWAY_PORT` | Gateway 端口 | `18789` |
| `GATEWAY_BIND` | 绑定地址 | `127.0.0.1` 或 `0.0.0.0` |
| `OPENCLAW_TZ` | 时区设置 | `Asia/Shanghai` |
| `NODE_ENV` | 运行环境 | `production` |
| `LOG_LEVEL` | 日志级别 | `info` |
| `OPENCLAW_DATA_DIR` | 数据目录 | `/app/data` |
| `OPENCLAW_CONFIG_DIR` | 配置目录 | `/app/config` |

### 健康检查接口

OpenClaw Gateway 提供以下健康检查端点：

- `GET /healthz`：存活检查
- `GET /readyz`：就绪检查
- 别名：`/health` 和 `/ready`

**健康检查配置**：
- 间隔：3 分钟
- 超时：10 秒
- 启动期：15 秒
- 重试次数：3

### 预装工具

| 工具 | 版本 | 用途 |
|-----|------|------|
| Python 3 | 系统版本 | 脚本执行、工具支持 |
| FFmpeg | 系统版本 | 多媒体处理 |
| FFprobe | 系统版本 | 多媒体分析 |
| Node.js | 24.x (Ubuntu 24.04/Debian)<br>22.x (Ubuntu 22.04) | JavaScript 运行时 |
| npm | 随 Node.js | 包管理器 |
| OpenClaw | latest 或指定版本 | AI 助手平台 |

---

## 关键依赖与配置

### 系统依赖

| 依赖类别 | 包名 | 用途 |
|---------|------|------|
| 基础工具 | curl, wget, gnupg, ca-certificates | 网络和证书管理 |
| Python | python3, python3-pip, python3-venv | Python 运行环境 |
| 多媒体 | ffmpeg | 音视频处理 |
| 实用工具 | git, vim, procps | 开发和调试 |

### 配置文件

| 文件 | 用途 | 关键参数 |
|-----|------|---------|
| `openclaw.default.conf` | 默认配置模板 | Gateway 端口、绑定地址、时区 |
| `versions.yaml` | 版本矩阵定义 | OpenClaw 版本、基础镜像列表 |

### 构建配置

**多架构支持**：
- linux/amd64
- linux/arm64

**版本矩阵**：
- OpenClaw：自动跟踪最新版本
- 基础镜像：Ubuntu 24.04/22.04、Debian Bookworm
- Node.js：24.x（Ubuntu 24.04/Debian）、22.x（Ubuntu 22.04）

---

## 数据模型

本模块为基础设施组件，不定义应用数据模型。OpenClaw 启动后由应用层管理数据。

**数据目录**：
- `/app/data`：应用数据
- `/app/config`：配置文件
- `/var/log/openclaw`：日志文件

---

## 测试与质量

### 构建验证

- **CI/CD**：GitHub Actions 自动构建（`.github/workflows/build-openclaw.yml`）
- **多平台支持**：linux/amd64, linux/arm64
- **缓存策略**：使用 GitHub Actions 缓存加速构建
- **版本检查**：自动检测并更新到最新版本

### 运行时验证

**healthcheck.sh** 执行：
```bash
# Gateway 健康检查
curl -f http://localhost:18789/healthz
```

### 基础镜像测试

CI 对所有基础镜像变体进行构建测试：
- Ubuntu 24.04（主构建）
- Ubuntu 22.04 LTS
- Debian Bookworm

---

## 常见问题 (FAQ)

### Q1: 如何选择基础镜像？

- **Ubuntu 24.04**（推荐）：最新功能，软件包最新
- **Ubuntu 22.04 LTS**：长期支持，稳定性优先
- **Debian Bookworm**：极致稳定，企业环境推荐

### Q2: 如何修改 OpenClaw 版本？

**方式一**：构建时指定
```bash
docker build --build-arg OPENCLAW_VERSION=2026.3.13 -t openclaw:2026.3.13 .
```

**方式二**：修改 `versions.yaml`
```yaml
openclaw:
  - "2026.3.13"
```

### Q3: 如何安装额外的 Python 包？

```bash
# 进入容器后安装
docker exec -it openclaw pip3 install <package>

# 或在 Dockerfile 中添加
RUN pip3 install --no-cache-dir <package>
```

### Q4: 如何暴露 Gateway 给外部访问？

默认绑定到 `127.0.0.1`，需修改为 `0.0.0.0`：

```bash
docker run -d \
  -p 18789:18789 \
  -e GATEWAY_BIND=0.0.0.0 \
  openclaw:latest
```

⚠️ **安全警告**：暴露到外网时务必配置认证！

### Q5: 如何自定义 FFmpeg 版本？

默认使用系统包管理器提供的版本。如需特定版本：

1. 在 Dockerfile 中添加 FFmpeg 仓库
2. 或编译安装特定版本

### Q6: 镜像体积过大怎么办？

优化建议：
1. 使用 `bookworm-slim` 基础镜像
2. 清理 apt 缓存：`apt-get clean && rm -rf /var/lib/apt/lists/*`
3. 减少预装工具数量

### Q7: 如何调试容器问题？

```bash
# 查看容器日志
docker logs openclaw

# 进入容器调试
docker exec -it openclaw /bin/bash

# 检查工具版本
docker exec openclaw python3 --version
docker exec openclaw ffmpeg -version
```

---

## 相关文件清单

### 核心文件

| 文件 | 类型 | 描述 |
|-----|------|------|
| `Dockerfile` | 构建文件 | 主构建定义（Ubuntu 24.04）|
| `Dockerfile.ubuntu22` | 构建文件 | Ubuntu 22.04 变体 |
| `Dockerfile.debian` | 构建文件 | Debian Bookworm 变体 |
| `docker-compose.yml` | 编排文件 | 本地开发配置 |
| `versions.yaml` | 配置文件 | 版本矩阵定义 |

### 脚本文件

| 文件 | 描述 |
|-----|------|
| `scripts/entrypoint.sh` | 容器入口脚本，处理初始化和启动 |
| `scripts/healthcheck.sh` | 健康检查脚本 |
| `scripts/download-latest.sh` | 自动下载最新版本脚本 |
| `scripts/install-tools.sh` | 额外工具安装脚本 |

### 配置文件

| 文件 | 描述 |
|-----|------|
| `config/openclaw.default.conf` | 默认配置模板 |
| `.dockerignore` | Docker 构建忽略文件 |

---

## 扩展阅读

- [OpenClaw 官方文档](https://docs.openclaw.ai)
- [OpenClaw GitHub 仓库](https://github.com/openclaw/openclaw)
- [Docker 最佳实践](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [FFmpeg 文档](https://ffmpeg.org/documentation.html)