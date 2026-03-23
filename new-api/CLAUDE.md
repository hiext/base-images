[根目录](../CLAUDE.md) > **new-api**

---

# new-api 模块文档

> 最后更新：2026-03-23

## 变更记录 (Changelog)

### 2026-03-23
- 初始化 new-api 模块
- 创建多阶段构建 Dockerfile
- 集成 GitHub Actions 自动构建

---

## 模块职责

new-api 模块负责构建自定义的 new-api Docker 镜像，为 AI 模型聚合和分发提供网关服务。主要功能包括：

1. 提供统一的 AI 模型 API 网关
2. 支持多种 LLM（OpenAI、Claude、Gemini 等）
3. 自动版本跟踪
4. 提供健康检查和配置管理
5. 支持多架构（amd64/arm64）

---

## 入口与启动

### Dockerfile 构建入口

**主构建文件**：`Dockerfile`

**构建参数**：
- `NEW_API_VERSION`：new-api 版本（默认：latest）

**基础镜像**：debian:bookworm-slim

**入口脚本**：
- `/usr/local/bin/entrypoint.sh`：容器启动入口
- `/usr/local/bin/healthcheck.sh`：健康检查脚本

### docker-compose 本地启动

**文件**：`docker-compose.yml`

**配置要点**：
- 使用非 root 用户运行（newapi:1000）
- 支持数据持久化（/data）
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
| `PORT` | 监听端口 | `3000` |
| `TZ` | 时区设置 | `Asia/Shanghai` |
| `SESSION_SECRET` | 会话密钥 | `your_secret_key` |
| `SQL_DSN` | 数据库连接字符串（可选） | `postgres://user:pass@host/db` |

### 健康检查接口

new-api 提供以下健康检查端点：

- `GET /api/status`：服务状态检查

**健康检查配置**：
- 间隔：3 分钟
- 超时：10 秒
- 启动期：15 秒
- 重试次数：3

---

## 关键依赖与配置

### 构建依赖

| 依赖类别 | 来源 | 用途 |
|---------|------|------|
| Go 1.21+ | golang:alpine | 后端编译 |
| Bun | oven/bun:latest | 前端构建 |
| Node.js | 随 Bun 安装 | 前端依赖 |

### 配置文件

| 文件 | 用途 | 关键参数 |
|-----|------|---------|
| `versions.yaml` | 版本矩阵定义 | new-api 版本、基础镜像 |

### 构建配置

**多架构支持**：
- linux/amd64
- linux/arm64

**版本矩阵**：
- new-api：自动跟踪最新版本
- 基础镜像：Debian Bookworm Slim

---

## 数据模型

本模块为基础设施组件，不定义应用数据模型。new-api 启动后由应用层管理数据。

**数据目录**：
- `/data`：应用数据
- `/var/log/new-api`：日志文件

---

## 测试与质量

### 构建验证

- **CI/CD**：GitHub Actions 自动构建（`.github/workflows/build-new-api.yml`）
- **多平台支持**：linux/amd64, linux/arm64
- **缓存策略**：使用 GitHub Actions 缓存加速构建

### 运行时验证

**healthcheck.sh** 执行：
```bash
# 服务健康检查
curl -f http://localhost:3000/api/status
```

---

## 常见问题 (FAQ)

### Q1: 如何选择数据库？

new-api 支持多种数据库：
- **SQLite**（默认）：无需配置，适合测试
- **PostgreSQL**：生产环境推荐，配置 `SQL_DSN`
- **MySQL**：可选，配置 `SQL_DSN`

### Q2: 如何修改监听端口？

修改环境变量 `PORT`：
```bash
docker run -e PORT=8080 -p 8080:8080 new-api:latest
```

### Q3: 如何配置 AI 模型？

1. 访问 Web UI：http://localhost:3000
2. 登录管理后台
3. 在"渠道"页面添加 AI 模型配置
4. 配置 API 密钥和端点

### Q4: 如何持久化数据？

挂载数据卷：
```bash
docker run -v $(pwd)/data:/data new-api:latest
```

### Q5: 镜像体积过大怎么办？

当前基于 Debian Bookworm Slim，已优化体积。进一步优化：
1. 使用 Alpine 基础镜像（需测试兼容性）
2. 清理不必要的依赖

---

## 相关文件清单

### 核心文件

| 文件 | 类型 | 描述 |
|-----|------|------|
| `Dockerfile` | 构建文件 | 多阶段构建定义 |
| `docker-compose.yml` | 编排文件 | 本地开发配置 |
| `versions.yaml` | 配置文件 | 版本矩阵定义 |

### 脚本文件

| 文件 | 描述 |
|-----|------|
| `scripts/entrypoint.sh` | 容器入口脚本，处理初始化和启动 |
| `scripts/healthcheck.sh` | 健康检查脚本 |

---

## 扩展阅读

- [new-api 官方仓库](https://github.com/QuantumNous/new-api)
- [new-api 官方文档](https://github.com/QuantumNous/new-api#readme)
- [Docker 最佳实践](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)