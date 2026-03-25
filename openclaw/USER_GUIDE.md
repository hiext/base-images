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

---

## 🚀 快速开始

### 前置要求

- Docker 20.10+ 和 Docker Compose
- 至少 2GB 内存
- 确保没有进程占用 18789 端口

### 首次部署（推荐）

**为什么需要初始化？** OpenClaw 首次启动时会生成访问令牌和配置文件，必须完成初始化才能正常运行。

```bash
# 1. 创建工作目录
mkdir openclaw && cd openclaw

# 2. 下载 docker-compose 配置（已包含初始化设置）
curl -O https://raw.githubusercontent.com/hiext/base-images/main/openclaw/docker-compose.user.yml
mv docker-compose.user.yml docker-compose.yml

# 3. 创建必要的数据目录（⚠️ 必须执行！）
mkdir -p data config logs
mkdir -p ~/.openclaw  # 重要：用于保存初始化配置

# 4. 启动服务
# 注意：首次启动可能需要 1-2 分钟完成初始化
docker compose up -d

# 5. 查看实时日志，等待初始化完成
# 看到 "[gateway] listening on ws://..." 表示启动成功
docker compose logs -f

# 按 Ctrl+C 退出日志查看

# 6. 获取访问令牌（首次启动会自动生成）
echo "=== Gateway Token ==="
cat ~/.openclaw/config/gateway.token 2>/dev/null || \
  docker compose exec openclaw cat /home/node/.openclaw/config/gateway.token

# 7. 验证运行状态
curl http://localhost:18789/healthz
# 应返回 {"status":"ok"}
```

### 各步骤说明

<details>
<summary>点击展开详细说明</summary>

#### 第 3 步：创建目录
```bash
mkdir -p data config logs ~/.openclaw
```
- `data/` - 应用数据持久化
- `config/` - 配置文件
- `logs/` - 日志文件
- `~/.openclaw/` - **关键！** OpenClaw 初始化配置目录

#### 第 4 步：启动
```bash
docker compose up -d
```
- `-d` 表示后台运行
- 首次启动会下载镜像（约 300MB）

#### 第 5 步：查看日志
```bash
docker compose logs -f
```

**成功启动的标志：**
```
[gateway] auth token was missing. Generated a new token...
[gateway] listening on ws://127.0.0.1:18789, ws://[::1]:18789
[heartbeat] started
[health-monitor] started
```

**如果看到反复重启的错误：**
```
Error: configuration required
```
这是因为缺少初始化配置，请检查是否正确挂载了 `~/.openclaw` 目录。

#### 第 6 步：获取 Token
初始化完成后，Gateway 会自动生成访问令牌：
```bash
cat ~/.openclaw/config/gateway.token
```

</details>

---

## 📋 配置说明

### 环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `GATEWAY_BIND` | `0.0.0.0` | **绑定地址**，`0.0.0.0` 允许外部，`127.0.0.1` 仅本地 |
| `LOG_LEVEL` | `info` | 日志级别：debug/info/warn/error |
| `OPENCLAW_TZ` | `Asia/Shanghai` | 时区设置 |
| `NODE_ENV` | `production` | 运行环境 |
| `GATEWAY_ALLOW_UNCONFIGURED` | `true` | **首次启动必须设为 true**，初始化后可移除 |

### 挂载目录

```yaml
volumes:
  - ./data:/app/data              # 应用数据（持久化）
  - ./config:/app/config          # 配置文件
  - ./logs:/var/log/openclaw      # 日志文件
  - ~/.openclaw:/home/node/.openclaw  # ⚠️ 关键！初始化配置
```

**重要：** `~/.openclaw` 必须正确挂载到容器内的 `/home/node/.openclaw`，否则容器会反复重启。

---

## 🔧 常用操作

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
tar czvf openclaw-backup-$(date +%Y%m%d).tar.gz \
  data/ config/ logs/ ~/.openclaw/
```

---

## 🐛 故障排除

### 容器反复重启

**症状：** `docker compose ps` 显示容器状态为 `Restarting`

**原因：** 缺少初始化配置

**解决步骤：**

1. 检查目录是否存在：
```bash
ls -la ~/.openclaw
# 如果不存在，创建它
mkdir -p ~/.openclaw
```

2. 确认 docker-compose.yml 中正确挂载：
```yaml
volumes:
  - ~/.openclaw:/home/node/.openclaw
```

3. 确认环境变量设置正确：
```yaml
environment:
  - GATEWAY_ALLOW_UNCONFIGURED=true
```

4. 重启容器：
```bash
docker compose down
docker compose up -d
```

### 端口被占用

```bash
# 检查 18789 端口占用
lsof -i :18789

# 修改为其他端口（如需）
# 编辑 docker-compose.yml，修改 ports:
#   - "18889:18789"  # 使用 18889 代替 18789
```

### 权限问题

```bash
# 修复数据目录权限
sudo chown -R $(id -u):$(id -g) data/ config/ logs/ ~/.openclaw/
docker compose restart
```

### 无法获取 Token

如果 `~/.openclaw/config/gateway.token` 文件不存在：

```bash
# 等待容器启动完成
docker compose logs -f

# 如果一切正常但 token 不存在，手动从容器获取
docker compose exec openclaw \
  cat /home/node/.openclaw/config/gateway.token
```

### 初始化后修改配置

**初始化完成后，建议移除 `GATEWAY_ALLOW_UNCONFIGURED`：**

编辑 `docker-compose.yml`，删除或注释掉：
```yaml
# - GATEWAY_ALLOW_UNCONFIGURED=true
```

然后重启：
```bash
docker compose down
docker compose up -d
```

---

## 📝 完整 docker-compose.yml 示例

```yaml
services:
  openclaw:
    image: ghcr.io/hiext/openclaw:latest
    container_name: openclaw-gateway
    ports:
      - "18789:18789"
    environment:
      - OPENCLAW_TZ=Asia/Shanghai
      - NODE_ENV=production
      - GATEWAY_BIND=0.0.0.0
      - LOG_LEVEL=info
      # 首次启动需要，初始化后可移除
      - GATEWAY_ALLOW_UNCONFIGURED=true
    volumes:
      - ./data:/app/data
      - ./config:/app/config
      - ./logs:/var/log/openclaw
      # ⚠️ 关键！必须挂载
      - ~/.openclaw:/home/node/.openclaw
    restart: unless-stopped
    command: ["node", "openclaw.mjs", "gateway", "--allow-unconfigured"]
```

---

## 🔐 安全指南

### 暴露到外网

如果将 OpenClaw 暴露到公网，必须配置认证：

1. 获取初始化生成的 token
2. 不要设置 `GATEWAY_ALLOW_UNCONFIGURED=true`
3. 所有请求都需要携带 Token

```yaml
environment:
  - GATEWAY_BIND=0.0.0.0
  # 生产环境不要设置 GATEWAY_ALLOW_UNCONFIGURED
```

### 防火墙配置

```bash
# 限制只允许本地访问（推荐）
ports:
  - "127.0.0.1:18789:18789"
```

---

## 📚 参考资源

- [OpenClaw 官方文档](https://docs.openclaw.ai)
- [OpenClaw GitHub](https://github.com/openclaw/openclaw)
- [本仓库完整配置](https://github.com/hiext/base-images/tree/main/openclaw)

---

## 更新日志

### 2026-03-25
- **修复**：添加初始化流程说明，解决容器反复重启问题
- **新增**：`~/.openclaw` 挂载说明
- **新增**：`GATEWAY_ALLOW_UNCONFIGURED` 环境变量
- **新增**：详细的故障排除指南

### 2026-03-24
- 新增用户版 docker-compose 配置
- 支持预构建镜像快速部署
- 完善文档和使用指南
