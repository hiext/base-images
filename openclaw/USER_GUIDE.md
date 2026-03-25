# OpenClaw 用户使用指南

## 镜像说明

本部署使用 **hiext/openclaw** 扩展镜像，基于 [OpenClaw 官方镜像](https://github.com/openclaw/openclaw) 构建：

| 镜像 | 说明 |
|------|------|
| `ghcr.io/openclaw/openclaw:latest` | 官方纯净镜像 |
| `ghcr.io/hiext/openclaw:latest` | **本镜像** = 官方 + 扩展工具 |

### 扩展内容

在官方镜像基础上预装以下工具：

```
Python 3.11   - 脚本执行、AI 工具支持
FFmpeg 5.1   - 多媒体处理
Git          - 版本控制
curl         - HTTP 请求
wget         - 文件下载
vim          - 文本编辑
```

**为什么要扩展？** 官方镜像保持精简，我们添加常用工具以支持更多 AI 工作流场景。

## 快速开始

### 方式一：使用预构建镜像（推荐）

```bash
# 1. 创建工作目录
mkdir openclaw && cd openclaw

# 2. 下载 docker-compose 配置
curl -O https://raw.githubusercontent.com/hiext/base-images/main/openclaw/docker-compose.user.yml
mv docker-compose.user.yml docker-compose.yml

# 3. 创建必要的数据目录
mkdir -p data config logs

# 4. 启动服务
docker compose up -d

# 5. 查看状态
docker compose ps
docker compose logs -f
```

### 方式二：本地构建（高级用户）

```bash
# 克隆仓库并构建
git clone https://github.com/hiext/base-images.git
cd base-images/openclaw
docker compose up -d --build
```

---

## 访问 OpenClaw

服务启动后，可以通过以下方式访问：

| 端点 | 地址 | 说明 |
|------|------|------|
| **Gateway WebSocket** | `ws://localhost:18789` | 主要连接地址 |
| **健康检查** | `http://localhost:18789/healthz` | 服务状态 |
| **浏览器控制** | `http://localhost:18791/` | 浏览器自动化 |

### 验证运行状态

```bash
# 检查容器状态
docker compose ps

# 查看实时日志
docker compose logs -f

# 健康检查
curl http://localhost:18789/healthz
```

---

## 配置说明

### 环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `GATEWAY_BIND` | `0.0.0.0` | **绑定地址**，`0.0.0.0` 允许外部，`127.0.0.1` 仅本地 |
| `LOG_LEVEL` | `info` | 日志级别：debug/info/warn/error |
| `OPENCLAW_TZ` | `Asia/Shanghai` | 时区设置 |
| `NODE_ENV` | `production` | 运行环境 |

### 挂载目录

```yaml
volumes:
  - ./data:/app/data      # 应用数据（持久化）
  - ./config:/app/config  # 配置文件
  - ./logs:/var/log/openclaw  # 日志文件
```

**首次启动时会自动生成配置文件到 `config/` 目录。**

---

## 常用操作

### 服务管理

```bash
# 启动
docker compose up -d

# 停止
docker compose down

# 重启
docker compose restart

# 查看日志
docker compose logs -f

# 查看最近 100 行日志
docker compose logs --tail=100
```

### 更新镜像

```bash
# 拉取最新镜像
docker compose pull

# 重启使用新镜像
docker compose up -d
```

### 进入容器

```bash
# 进入容器 Shell
docker compose exec openclaw /bin/bash

# 检查 Python 版本
docker compose exec openclaw python3 --version

# 检查 FFmpeg 版本
docker compose exec openclaw ffmpeg -version
```

### 数据备份

```bash
# 备份数据目录
tar czvf openclaw-backup-$(date +%Y%m%d).tar.gz data/ config/ logs/
```

---

## 故障排除

### 端口被占用

```bash
# 检查 18789 端口占用
lsof -i :18789

# 修改 docker-compose.yml 中的端口映射
ports:
  - "18889:18789"  # 使用 18889 代替 18789
```

### 权限问题

```bash
# 修复数据目录权限
sudo chown -R $(id -u):$(id -g) data/ config/ logs/
docker compose restart
```

### 容器无法启动

```bash
# 查看详细错误日志
docker compose logs --no-color

# 检查配置文件
cat config/openclaw.json
```

### 健康检查失败

```bash
# 检查容器内服务状态
docker compose exec openclaw ps aux

# 查看 OpenClaw 日志
docker compose exec openclaw cat /tmp/openclaw/openclaw-*.log
```

---

## 系统要求

| 资源 | 最低配置 | 推荐配置 |
|------|----------|----------|
| CPU | 2 核 | 4 核 |
| 内存 | 2 GB | 4 GB |
| 磁盘 | 10 GB | 20 GB+ |
| Docker | 20.10+ | 24.0+ |

---

## 安全说明

⚠️ **重要**：如果将 OpenClaw 暴露到公网，建议：

1. 使用反向代理（Nginx/Traefik）并配置 HTTPS
2. 设置强密码或 Token 认证
3. 限制访问 IP （防火墙规则）
4. 定期更新镜像到最新版本

```yaml
# 示例：仅本地访问（更安全）
environment:
  - GATEWAY_BIND=127.0.0.1
ports:
  - "127.0.0.1:18789:18789"  # 仅本地可访问
```

---

## 预装工具

OpenClaw 镜像已预装以下工具：

| 工具 | 用途 |
|------|------|
| Python 3.11 | 脚本执行 |
| FFmpeg 5.1 | 多媒体处理 |
| Git | 版本控制 |
| curl/wget | 网络请求 |
| vim | 文本编辑 |
| Node.js | JavaScript 运行 |

---

## 获取帮助

- **OpenClaw 官方文档**: https://docs.openclaw.ai
- **GitHub 仓库**: https://github.com/openclaw/openclaw
- **提交 Issue**: https://github.com/hiext/base-images/issues

---

## 更新日志

### 2026-03-24
- 新增用户版 docker-compose 配置
- 支持预构建镜像快速部署
- 完善文档和使用指南
