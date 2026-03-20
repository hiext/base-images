# OpenClaw 快速参考卡

> 🎯 一页纸快速查询指南

---

## 📦 镜像信息

| 项目 | 信息 |
|-----|------|
| **仓库** | ghcr.io/hiext/openclaw |
| **标签** | `latest`, `latest-ubuntu22`, `latest-debian`, `2026.3.13` |
| **架构** | linux/amd64, linux/arm64 |
| **大小** | ~800MB |

---

## 🚀 快速启动

### Docker 命令

```bash
# 拉取镜像
docker pull ghcr.io/hiext/openclaw:latest

# 运行容器
docker run -d \
  --name openclaw \
  -p 18789:18789 \
  -e GATEWAY_BIND=0.0.0.0 \
  ghcr.io/hiext/openclaw:latest

# 查看日志
docker logs -f openclaw

# 健康检查
curl http://localhost:18789/healthz
```

### Docker Compose

```bash
# 启动
docker-compose up -d

# 停止
docker-compose down

# 日志
docker-compose logs -f
```

---

## 🔧 构建命令

### 本地构建

```bash
# 默认构建（Ubuntu 24.04）
docker build -t openclaw:local .

# Ubuntu 22.04
docker build \
  --build-arg BASE_IMAGE=ubuntu:22.04 \
  --build-arg NODE_VERSION=22 \
  -t openclaw:ubuntu22 .

# Debian
docker build \
  --build-arg BASE_IMAGE=debian:bookworm \
  -t openclaw:debian .

# 指定版本
docker build \
  --build-arg OPENCLAW_VERSION=2026.3.13 \
  -t openclaw:2026.3.13 .
```

### 多架构构建

```bash
# 设置 QEMU
docker run --privileged --rm tonistiigi/binfmt --install all

# 构建多架构镜像
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t openclaw:multiarch \
  .
```

---

## 🛠️ 常用命令

### 容器管理

```bash
# 启动
docker start openclaw

# 停止
docker stop openclaw

# 重启
docker restart openclaw

# 删除
docker rm -f openclaw

# 进入容器
docker exec -it openclaw /bin/bash
```

### 日志查看

```bash
# 实时日志
docker logs -f openclaw

# 最近 100 行
docker logs --tail 100 openclaw

# 带时间戳
docker logs -t openclaw
```

### 资源监控

```bash
# 查看资源使用
docker stats openclaw

# 查看进程
docker top openclaw

# 查看端口
docker port openclaw
```

---

## ⚙️ 环境变量

| 变量 | 默认值 | 说明 |
|-----|--------|------|
| `GATEWAY_PORT` | `18789` | Gateway 端口 |
| `GATEWAY_BIND` | `127.0.0.1` | 绑定地址 |
| `OPENCLAW_TZ` | `UTC` | 时区 |
| `NODE_ENV` | `production` | 环境 |
| `LOG_LEVEL` | `info` | 日志级别 |
| `ENABLE_AUTH` | `false` | 启用认证 |

---

## 🔍 预装工具

| 工具 | 命令 |
|-----|------|
| **Python** | `python3 --version` |
| **FFmpeg** | `ffmpeg -version` |
| **FFprobe** | `ffprobe -version` |
| **Node.js** | `node --version` |
| **npm** | `npm --version` |
| **OpenClaw** | `openclaw --version` |

---

## 🐛 故障排查

### 容器无法启动

```bash
# 查看日志
docker logs openclaw

# 检查端口冲突
netstat -tlnp | grep 18789

# 检查权限
docker run --user root openclaw:latest
```

### 健康检查失败

```bash
# 手动检查
docker exec openclaw /usr/local/bin/healthcheck.sh

# 测试端点
docker exec openclaw curl http://localhost:18789/healthz

# 查看详细日志
docker logs --tail 200 openclaw
```

### 镜像拉取失败

```bash
# 登录 GHCR
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

# 验证镜像
docker pull ghcr.io/hiext/openclaw:latest
```

---

## 📂 目录结构

```
/app/
├── data/              # 数据目录
├── config/            # 配置文件
└── logs/              # 日志文件

/etc/openclaw/
└── openclaw.default.conf  # 默认配置

/usr/local/bin/
├── entrypoint.sh      # 启动脚本
├── healthcheck.sh     # 健康检查
└── install-tools.sh   # 工具安装
```

---

## 🔐 生产部署清单

- [ ] 设置 `GATEWAY_BIND=127.0.0.1`（或配置认证）
- [ ] 配置数据持久化卷
- [ ] 设置资源限制（CPU/内存）
- [ ] 配置日志轮转
- [ ] 启用认证（`ENABLE_AUTH=true`）
- [ ] 设置强 JWT 密钥
- [ ] 配置 HTTPS/TLS
- [ ] 设置防火墙规则
- [ ] 配置监控告警
- [ ] 测试备份恢复

---

## 📚 相关链接

- 📖 [完整部署文档](./DEPLOYMENT.md)
- 📝 [模块文档](./CLAUDE.md)
- 🌐 [OpenClaw 官方](https://openclaw.ai)
- 🐙 [GitHub 仓库](https://github.com/hiext/base-images)

---

## 💡 快速示例

### 最小化部署

```bash
docker run -d -p 18789:18789 ghcr.io/hiext/openclaw:latest
```

### 完整部署

```bash
docker run -d \
  --name openclaw \
  -p 18789:18789 \
  -e GATEWAY_BIND=0.0.0.0 \
  -e OPENCLAW_TZ=Asia/Shanghai \
  -e ENABLE_AUTH=true \
  -v $(pwd)/data:/app/data \
  -v $(pwd)/config:/app/config \
  --memory=4g \
  --cpus=2 \
  ghcr.io/hiext/openclaw:latest
```

### 验证部署

```bash
# 健康检查
curl http://localhost:18789/healthz

# 版本验证
docker exec openclaw openclaw --version

# 工具验证
docker exec openclaw python3 --version
docker exec openclaw ffmpeg -version
```

---

**打印此页作为快速参考！**