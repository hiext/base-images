# OpenClaw 镜像部署和使用指南

> 📖 本文档提供 OpenClaw 镜像的完整部署、测试和使用指南
>
> 最后更新：2026-03-20

---

## 📚 目录

1. [本地构建测试](#本地构建测试)
2. [CI/CD 触发方式](#cicd-触发方式)
3. [功能扩展建议](#功能扩展建议)
4. [故障排查指南](#故障排查指南)
5. [生产部署清单](#生产部署清单)

---

## 🔨 本地构建测试

### 前置要求

**必需软件**：
- Docker Engine 24.0+
- Docker Buildx（多架构支持）
- Git

**推荐配置**：
- CPU: 4 核心以上
- 内存: 8GB 以上
- 磁盘: 20GB 可用空间

### 步骤 1: 克隆仓库

```bash
# 克隆仓库
git clone https://github.com/hiext/base-images.git
cd base-images

# 查看项目结构
tree openclaw -L 2
```

### 步骤 2: 构建镜像

#### 2.1 默认构建（Ubuntu 24.04）

```bash
cd openclaw

# 构建默认镜像
docker build -t openclaw:test-ubuntu24 .

# 查看镜像大小
docker images openclaw:test-ubuntu24
```

**预期输出**：
```
REPOSITORY   TAG               IMAGE ID       CREATED         SIZE
openclaw     test-ubuntu24     abc123def456   2 minutes ago   ~800MB
```

#### 2.2 构建 Ubuntu 22.04 变体

```bash
# 构建 Ubuntu 22.04 变体
docker build \
  --build-arg BASE_IMAGE=ubuntu:22.04 \
  --build-arg NODE_VERSION=22 \
  -t openclaw:test-ubuntu22 \
  .
```

#### 2.3 构建 Debian Bookworm 变体

```bash
# 构建 Debian 变体
docker build \
  --build-arg BASE_IMAGE=debian:bookworm \
  -t openclaw:test-debian \
  .
```

#### 2.4 指定 OpenClaw 版本

```bash
# 构建指定版本
docker build \
  --build-arg OPENCLAW_VERSION=2026.3.13 \
  -t openclaw:2026.3.13 \
  .
```

### 步骤 3: 验证预装工具

#### 3.1 验证 Python

```bash
docker run --rm openclaw:test-ubuntu24 python3 --version
```

**预期输出**：
```
Python 3.12.x
```

#### 3.2 验证 FFmpeg

```bash
docker run --rm openclaw:test-ubuntu24 ffmpeg -version
```

**预期输出**：
```
ffmpeg version 6.x ...
```

#### 3.3 验证 OpenClaw

```bash
docker run --rm openclaw:test-ubuntu24 openclaw --version
```

**预期输出**：
```
2026.3.13
```

### 步骤 4: 运行容器测试

#### 4.1 基本运行

```bash
# 启动容器
docker run -d \
  --name openclaw-test \
  -p 18789:18789 \
  -e GATEWAY_BIND=0.0.0.0 \
  openclaw:test-ubuntu24

# 查看日志
docker logs -f openclaw-test
```

#### 4.2 健康检查测试

```bash
# 等待容器启动（约 15 秒）
sleep 15

# 检查容器状态
docker ps | grep openclaw-test

# 测试健康端点
curl http://localhost:18789/healthz

# 预期输出：OK 或 200 状态码
```

#### 4.3 功能测试

```bash
# 进入容器
docker exec -it openclaw-test /bin/bash

# 在容器内执行
openclaw --help
python3 -c "import sys; print(sys.version)"
ffmpeg -version

# 退出容器
exit
```

#### 4.4 清理测试环境

```bash
# 停止并删除容器
docker stop openclaw-test
docker rm openclaw-test

# 删除测试镜像
docker rmi openclaw:test-ubuntu24
```

### 步骤 5: Docker Compose 测试

```bash
# 使用 docker-compose 启动
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f openclaw

# 测试健康检查
curl http://localhost:18789/healthz

# 停止服务
docker-compose down
```

---

## 🚀 CI/CD 触发方式

### 方式 1: 自动触发（推荐）

#### 1.1 推送到 main 分支

```bash
# 修改文件
echo "# Update" >> openclaw/README.md

# 提交并推送
git add openclaw/README.md
git commit -m "docs: update README"
git push origin main
```

**CI/CD 行为**：
- ✅ 自动检测 `openclaw/` 目录变更
- ✅ 触发构建所有基础镜像变体
- ✅ 自动推送到 `ghcr.io`

#### 1.2 定时构建（每周）

- ⏰ 每周日 00:00 UTC 自动执行
- ✅ 检查 OpenClaw 最新版本
- ✅ 如有更新，自动构建并推送

### 方式 2: 手动触发

#### 2.1 GitHub Web 界面

1. 访问仓库：https://github.com/hiext/base-images
2. 点击 **Actions** 标签
3. 选择 **Build and Push OpenClaw Images** 工作流
4. 点击 **Run workflow** 按钮
5. 选择分支（默认 main）
6. 点击 **Run workflow** 确认

#### 2.2 GitHub CLI

```bash
# 安装 GitHub CLI
# macOS: brew install gh
# Linux: 参见 https://cli.github.com/

# 登录 GitHub
gh auth login

# 手动触发工作流
gh workflow run build-openclaw.yml

# 查看工作流状态
gh run list --workflow=build-openclaw.yml
```

#### 2.3 API 触发

```bash
# 使用 curl 触发
curl -X POST \
  -H "Authorization: token YOUR_GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/hiext/base-images/actions/workflows/build-openclaw.yml/dispatches \
  -d '{"ref":"main"}'
```

### 方式 3: Pull Request 触发

```bash
# 创建新分支
git checkout -b feature/openclaw-update

# 修改文件
vim openclaw/Dockerfile

# 提交并推送
git add openclaw/Dockerfile
git commit -m "feat: update openclaw configuration"
git push origin feature/openclaw-update

# 创建 Pull Request
gh pr create --title "Update OpenClaw configuration" --body "Description..."
```

**CI/CD 行为**：
- ✅ 自动构建测试（不推送镜像）
- ✅ PR 检查通过后可合并
- ⚠️ 不会推送到 ghcr.io（仅测试构建）

### 查看构建结果

#### GitHub Web 界面

1. 访问 **Actions** 标签
2. 点击具体的工作流运行记录
3. 查看详细日志和构建产物

#### GitHub CLI

```bash
# 列出最近的工作流运行
gh run list --workflow=build-openclaw.yml --limit 5

# 查看特定运行的详细信息
gh run view RUN_ID

# 查看运行日志
gh run view RUN_ID --log
```

---

## 💡 功能扩展建议

### 扩展 1: 添加更多预装工具

#### 场景
需要预装额外的开发或调试工具。

#### 实施步骤

**1. 编辑 Dockerfile**

```dockerfile
# 在 deps 阶段添加工具
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        # 现有工具...
        # 新增工具
        htop \
        tree \
        jq \
        ; \
    apt-get clean
```

**2. 验证安装**

```bash
docker build -t openclaw:extended .
docker run --rm openclaw:extended htop --version
docker run --rm openclaw:extended jq --version
```

**3. 更新文档**

更新 `openclaw/README.md` 和 `openclaw/CLAUDE.md` 中的工具列表。

### 扩展 2: 支持自定义 Python 包

#### 场景
需要预装特定的 Python 包（如 numpy、pandas）。

#### 实施步骤

**方法 1: 在 Dockerfile 中安装**

```dockerfile
# 在 runtime 阶段添加
RUN pip3 install --no-cache-dir \
    numpy \
    pandas \
    requests
```

**方法 2: 使用 requirements.txt**

```bash
# 创建 requirements.txt
cat > openclaw/requirements.txt << EOF
numpy==1.26.0
pandas==2.2.0
requests==2.31.0
EOF
```

```dockerfile
# 在 Dockerfile 中添加
COPY requirements.txt /tmp/
RUN pip3 install --no-cache-dir -r /tmp/requirements.txt
```

**验证**：

```bash
docker run --rm openclaw:extended python3 -c "import numpy; print(numpy.__version__)"
```

### 扩展 3: 添加配置文件模板

#### 场景
提供更多配置选项和模板。

#### 实施步骤

**1. 创建配置模板**

```bash
mkdir -p openclaw/config/templates

# 创建生产环境配置
cat > openclaw/config/templates/openclaw.production.conf << EOF
# 生产环境配置
GATEWAY_BIND=0.0.0.0
ENABLE_AUTH=true
LOG_LEVEL=warning
MAX_MEMORY=4096
EOF

# 创建开发环境配置
cat > openclaw/config/templates/openclaw.development.conf << EOF
# 开发环境配置
GATEWAY_BIND=127.0.0.1
ENABLE_AUTH=false
LOG_LEVEL=debug
DEBUG_MODE=true
EOF
```

**2. 更新 entrypoint.sh**

```bash
# 在 entrypoint.sh 中添加配置选择逻辑
apply_config_template() {
    local env="${OPENCLAW_ENV:-production}"
    local template="/app/config/templates/openclaw.${env}.conf"

    if [[ -f "$template" ]]; then
        log_info "应用配置模板: $env"
        cp "$template" /app/config/openclaw.conf
    fi
}
```

**3. 使用配置**

```bash
docker run -d \
  -e OPENCLAW_ENV=development \
  -v $(pwd)/config:/app/config \
  openclaw:latest
```

### 扩展 4: 集成监控和日志

#### 场景
集成 Prometheus 监控和 ELK 日志收集。

#### 实施步骤

**1. 添加 Prometheus Exporter**

```dockerfile
# 在 Dockerfile 中添加
RUN pip3 install --no-cache-dir prometheus_client

# 创建 metrics 端点脚本
COPY scripts/metrics.py /usr/local/bin/metrics.py
```

**2. 更新 docker-compose.yml**

```yaml
version: '3.8'
services:
  openclaw:
    # ... 现有配置
    labels:
      - "prometheus.io/scrape=true"
      - "prometheus.io/port=9090"
    expose:
      - "9090"
```

**3. 日志集成**

```yaml
services:
  openclaw:
    logging:
      driver: "json-file"
      options:
        max-size: "50m"
        max-file: "5"
        labels: "service,environment"
    labels:
      - "service=openclaw"
      - "environment=production"
```

### 扩展 5: 多阶段缓存优化

#### 场景
优化构建速度，利用 Docker 缓存。

#### 实施步骤

**优化 Dockerfile**

```dockerfile
# 使用 BuildKit 缓存挂载
# syntax=docker/dockerfile:1.7

FROM base AS deps
RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
    apt-get update && apt-get install -y ...

FROM deps AS nodejs
RUN --mount=type=cache,target=/root/.npm \
    npm install -g openclaw@${OPENCLAW_VERSION}
```

**构建命令**

```bash
# 使用 BuildKit
DOCKER_BUILDKIT=1 docker build -t openclaw:cached .
```

---

## 🔍 故障排查指南

### 问题 1: 构建失败 - 内存不足

**症状**：
```
ERROR: failed to solve: executor failed running [...]: exit code: 137
```

**原因**：Docker 构建过程中内存不足

**解决方案**：

```bash
# 方法 1: 增加 Docker 内存限制
# Docker Desktop -> Settings -> Resources -> Memory: 8GB+

# 方法 2: 使用 --memory 参数
docker build --memory=4g -t openclaw:latest .

# 方法 3: 使用 swap
docker build --memory-swap=8g -t openclaw:latest .
```

### 问题 2: 多架构构建失败

**症状**：
```
ERROR: executor failed running [/bin/sh -c ...]: fork/exec /bin/sh: exec format error
```

**原因**：QEMU 模拟器未正确设置

**解决方案**：

```bash
# 安装 QEMU 支持
docker run --privileged --rm tonistiigi/binfmt --install all

# 验证
docker buildx ls

# 重新构建
docker buildx build --platform linux/amd64,linux/arm64 -t openclaw:latest .
```

### 问题 3: 容器无法启动

**症状**：
```bash
docker ps -a
# STATUS: Exited (1)
```

**诊断步骤**：

```bash
# 1. 查看容器日志
docker logs openclaw-container

# 2. 检查配置
docker run --rm -it openclaw:latest /bin/bash
# 手动启动服务
openclaw gateway --verbose

# 3. 检查端口冲突
netstat -tlnp | grep 18789

# 4. 检查权限
docker run --rm openclaw:latest ls -la /app
```

**常见解决方案**：

```bash
# 端口冲突：更换端口
docker run -p 18790:18789 openclaw:latest

# 权限问题：使用 root 用户
docker run --user root openclaw:latest

# 配置错误：重置配置
docker run --rm -v openclaw-config:/app/config openclaw:latest rm /app/config/openclaw.conf
```

### 问题 4: 健康检查失败

**症状**：
```bash
docker ps
# STATUS: (unhealthy)
```

**诊断步骤**：

```bash
# 1. 手动执行健康检查
docker exec openclaw-container /usr/local/bin/healthcheck.sh
echo $?  # 查看退出码

# 2. 检查服务状态
docker exec openclaw-container curl -f http://localhost:18789/healthz

# 3. 查看详细日志
docker logs --tail 100 openclaw-container
```

**解决方案**：

```bash
# 增加启动等待时间
docker run \
  --health-start-period=30s \
  openclaw:latest

# 调整健康检查间隔
HEALTHCHECK --interval=5m --timeout=15s --retries=5 \
  CMD /usr/local/bin/healthcheck.sh
```

### 问题 5: 镜像拉取失败

**症状**：
```
Error: image 'ghcr.io/hiext/openclaw:latest' not found
```

**解决方案**：

```bash
# 1. 检查镜像是否存在
docker search ghcr.io/hiext/openclaw

# 2. 登录 GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

# 3. 验证权限
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://ghcr.io/v2/hiext/openclaw/tags/list

# 4. 使用正确的镜像名称
docker pull ghcr.io/hiext/openclaw:2026.3.13
```

### 问题 6: Python 包导入失败

**症状**：
```python
>>> import numpy
ModuleNotFoundError: No module named 'numpy'
```

**解决方案**：

```bash
# 1. 检查 Python 环境
docker run --rm openclaw:latest python3 -m pip list

# 2. 安装缺失的包
docker run --rm openclaw:latest python3 -m pip install numpy

# 3. 永久解决方案：修改 Dockerfile
RUN pip3 install --no-cache-dir numpy
```

---

## ✅ 生产部署清单

### 部署前检查

#### 1. 安全检查

- [ ] 配置了认证机制（`ENABLE_AUTH=true`）
- [ ] 使用 HTTPS/TLS 加密
- [ ] 设置了强密码和 JWT 密钥
- [ ] 限制了网络访问（防火墙规则）
- [ ] 定期更新镜像版本

#### 2. 配置检查

- [ ] 设置了正确的时区（`OPENCLAW_TZ`）
- [ ] 配置了数据持久化卷
- [ ] 设置了合理的资源限制
- [ ] 配置了日志轮转
- [ ] 设置了健康检查

#### 3. 监控检查

- [ ] 配置了日志收集
- [ ] 设置了资源监控
- [ ] 配置了告警规则
- [ ] 测试了备份恢复流程

### 生产环境配置示例

```yaml
version: '3.8'

services:
  openclaw:
    image: ghcr.io/hiext/openclaw:2026.3.13
    container_name: openclaw-prod

    # 端口配置
    ports:
      - "127.0.0.1:18789:18789"

    # 环境变量
    environment:
      - OPENCLAW_TZ=Asia/Shanghai
      - NODE_ENV=production
      - LOG_LEVEL=warning
      - GATEWAY_BIND=127.0.0.1
      - ENABLE_AUTH=true
      - JWT_SECRET=${JWT_SECRET}

    # 数据持久化
    volumes:
      - openclaw-data:/app/data
      - openclaw-config:/app/config
      - openclaw-logs:/var/log/openclaw

    # 资源限制
    deploy:
      resources:
        limits:
          cpus: '4'
          memory: 4G
        reservations:
          cpus: '1'
          memory: 1G
      restart_policy:
        condition: on-failure
        max_attempts: 3

    # 健康检查
    healthcheck:
      test: ["CMD", "/usr/local/bin/healthcheck.sh"]
      interval: 5m
      timeout: 10s
      retries: 3
      start_period: 30s

    # 日志配置
    logging:
      driver: "json-file"
      options:
        max-size: "50m"
        max-file: "5"

    # 安全配置
    security_opt:
      - no-new-privileges:true
    read_only: false

# 数据卷
volumes:
  openclaw-data:
    driver: local
  openclaw-config:
    driver: local
  openclaw-logs:
    driver: local
```

### 部署命令

```bash
# 1. 创建环境变量文件
cat > .env << EOF
JWT_SECRET=$(openssl rand -base64 32)
EOF

# 2. 拉取镜像
docker pull ghcr.io/hiext/openclaw:2026.3.13

# 3. 启动服务
docker-compose -f docker-compose.prod.yml up -d

# 4. 验证部署
docker-compose ps
docker-compose logs -f openclaw

# 5. 健康检查
curl http://localhost:18789/healthz

# 6. 备份配置
docker exec openclaw-prod tar czf /tmp/backup.tar.gz /app/config /app/data
docker cp openclaw-prod:/tmp/backup.tar.gz ./backup-$(date +%Y%m%d).tar.gz
```

### 更新流程

```bash
# 1. 备份数据
docker exec openclaw-prod tar czf /tmp/backup.tar.gz /app/data /app/config
docker cp openclaw-prod:/tmp/backup.tar.gz ./backup-pre-update.tar.gz

# 2. 拉取新镜像
docker pull ghcr.io/hiext/openclaw:2026.3.14

# 3. 停止旧容器
docker-compose down

# 4. 启动新容器
docker-compose up -d

# 5. 验证更新
docker-compose logs -f openclaw
curl http://localhost:18789/healthz

# 6. 如有问题，回滚
docker-compose down
docker tag ghcr.io/hiext/openclaw:2026.3.13 ghcr.io/hiext/openclaw:2026.3.14
docker-compose up -d
```

---

## 📚 相关文档

- [OpenClaw 官方文档](https://docs.openclaw.ai)
- [Docker 最佳实践](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [项目 CLAUDE.md](./CLAUDE.md)

---

## 🆘 获取帮助

如果遇到问题：

1. 📖 查阅本文档和 [故障排查指南](#故障排查指南)
2. 🔍 查看容器日志：`docker logs openclaw-container`
3. 🐛 提交 Issue：https://github.com/hiext/base-images/issues
4. 💬 讨论区：https://github.com/hiext/base-images/discussions

---

**文档版本**: v1.0
**最后更新**: 2026-03-20
**维护者**: hiext team