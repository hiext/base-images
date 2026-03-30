# OpenClaw 镜像测试指南

本文档说明如何在本地环境中测试 OpenClaw 镜像构建和功能。

## 环境要求

- Docker 24.0+（或 Podman）
- 可用网络连接（用于拉取基础镜像和安装依赖）

## 快速测试

### 1. 使用自动测试脚本

```bash
# 进入 openclaw 目录
cd openclaw

# 赋予执行权限
chmod +x test-build.sh

# 运行测试（将自动构建所有变体并测试）
./test-build.sh openclaw:test

# 测试结果将保存到 test-results-YYYYMMDD_HHMMSS.log
```

### 2. 手动测试步骤

#### 构建镜像

```bash
# 构建默认变体（Ubuntu 24.04）
docker build -t openclaw:test .

# 构建 Ubuntu 22.04 变体
docker build -t openclaw:ubuntu22 -f Dockerfile.ubuntu22 .

# 构建 Debian 变体
docker build -t openclaw:debian -f Dockerfile.debian .
```

## 功能验证

### 1. 验证 pip 镜像源配置

```bash
# 检查 pip 镜像源是否配置为清华大学 TUNA
docker run --rm openclaw:test pip3 config get global.index-url

# 预期输出:
# https://pypi.tuna.tsinghua.edu.cn/simple

# 验证 pip 配置
docker run --rm openclaw:test pip3 config list

# 预期显示:
# global.index-url='https://pypi.tuna.tsinghua.edu.cn/simple'
# global.trusted-host='pypi.tuna.tsinghua.edu.cn'
```

### 2. 验证 npm 镜像源配置

```bash
# 检查 npm 镜像源是否配置为淘宝镜像
docker run --rm openclaw:test npm config get registry

# 预期输出:
# https://registry.npmmirror.com/

# 验证 npm 配置
docker run --rm openclaw:test npm config list
```

### 3. 验证 Python 虚拟环境

```bash
# 测试创建虚拟环境
docker run --rm openclaw:test bash -c "python3 -m venv /tmp/test-venv && ls /tmp/test-venv/bin/"

# 预期输出:
# activate
# pip
# python
# python3
# ...

# 测试在虚拟环境中安装包
docker run --rm openclaw:test bash -c "
 python3 -m venv /tmp/test-venv
 source /tmp/test-venv/bin/activate
 pip install --dry-run requests
"
```

### 4. 验证 FFmpeg

```bash
# 验证 FFmpeg 版本
docker run --rm openclaw:test ffmpeg -version | head -1

# 预期输出类似:
# ffmpeg version 4.4.2 Copyright (c) 2000-2021 the FFmpeg developers
```

### 5. 验证 OpenClaw 基础功能

```bash
# 验证 Node.js 安装
docker run --rm openclaw:test node --version

# 验证用户
docker run --rm openclaw:test whoami
# 预期输出: node

# 验证工作目录
docker run --rm openclaw:test pwd
# 预期输出: /app
```

## 运行容器测试

### 启动容器

```bash
# 创建数据目录
mkdir -p data config logs

# 运行容器（基本模式）
docker run -d \
 --name openclaw-test \
 -p 18789:18789 \
 -v $(pwd)/data:/app/data \
 -v $(pwd)/config:/app/config \
 -v $(pwd)/logs:/var/log/openclaw \
 openclaw:test

# 查看容器日志
docker logs -f openclaw-test

# 等待健康检查
docker exec openclaw-test curl -f http://127.0.0.1:18789/healthz
```

### 测试真实使用场景

```bash
# 进入容器
docker exec -it openclaw-test bash

# ==== 测试 Python 开发环境 ====
# 1. 创建虚拟环境
cd /app/data
python3 -m venv myproject-venv
source myproject-venv/bin/activate

# 2. 安装包（使用清华镜像）
pip install requests pandas

# 3. 验证安装
python3 -c "import requests; print(requests.__version__)"

# 4. 退出虚拟环境
deactivate

# ==== 测试 Node.js 开发环境 ====
# 安装 npm 包（使用淘宝镜像）
npm install lodash axios

# 验证安装
npm ls lodash
```

## GitHub Actions 测试

### 本地测试工作流

使用 [act](https://github.com/nektos/act) 工具在本地测试 GitHub Actions：

```bash
# 安装 act
brew install act

# 进入项目根目录
cd /path/to/base-images

# 运行工作流（需要较大的 Docker 镜像）
act -j build-matrix -P ubuntu-latest=nektos/act-environments-ubuntu:18.04
```

### 手动推送测试

```bash
# 1. 提交更改
git add openclaw/
git commit -m "feat: add Chinese mirror sources for pip and npm"

# 2. 推送到分支（触发 CI/CD）
git push origin main

# 3. 监控 GitHub Actions 运行状态
gh workflow run build-openclaw.yml
gh workflow watch
```

## 多架构测试

由于多架构构建需要 Docker Buildx 和 QEMU，完整的多架构测试只能在 GitHub Actions 环境进行。

### 本地模拟多架构构建

```bash
# 安装 QEMU 模拟器
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

# 创建 buildx 构建器
docker buildx create --name multiarch-builder --use
docker buildx inspect --bootstrap

# 多架构构建测试（仅构建，不发布）
docker buildx build --platform linux/amd64,linux/arm64 -t openclaw:test --load .

# 验证 manifest
docker manifest inspect openclaw:test
```

## 基准测试

测试镜像下载速度对比：

```bash
# 时间戳
TIMEFORMAT='%3R'

# 使用官方源的对比（假设有另一个镜像）
echo "测试官方源镜像..."
time docker pull openclaw:official-source 2>/dev/null || echo "镜像不可用"

echo ""
echo "测试清华镜像源镜像..."
time docker pull openclaw:test
```

## 性能测试

测试 pip/npm 下载速度：

```bash
# 进入容器
docker run -it --rm openclaw:test bash

# 测试 pip 下载速度
time pip download requests --no-deps -d /tmp/pip-test

# 测试 npm 下载速度
cd /tmp && npm init -y
time npm install lodash --registry https://registry.npmmirror.com/

# 对比官方源
time npm install lodash --registry https://registry.npmjs.org/
```

## 故障排查

### Docker 构建失败

```bash
# 清理 Docker 缓存
docker system prune -a

# 重新构建
docker build --no-cache -t openclaw:test .
```

### 镜像源配置未生效

```bash
# 验证配置是否正确写入
docker run --rm openclaw:test cat /root/.config/pip/pip.conf
docker run --rm openclaw:test cat /home/node/.npmrc
```

### 多架构构建失败

```bash
# 检查 QEMU 是否安装
lsmod | grep binfmt_misc

# 重新安装 QEMU
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

# 创建新的 builder
docker buildx rm multiarch-builder
docker buildx create --name multiarch-builder --use
```

## 测试清单

### 基础功能

- [ ] Docker 构建成功
- [ ] 容器可以启动
- [ ] 健康检查通过
- [ ] Python 可以运行
- [ ] pip 可以安装包
- [ ] Node.js 可以运行
- [ ] npm 可以安装包
- [ ] FFmpeg 可以运行
- [ ] Git 可以运行

### 镜像源配置

- [ ] pip 自动使用清华镜像
- [ ] npm 自动使用淘宝镜像
- [ ] pip 包下载速度比官方源快
- [ ] npm 包下载速度比官方源快

### 虚拟环境

- [ ] Python venv 命令可用
- [ ] 可以创建虚拟环境
- [ ] 虚拟环境中 pip 走清华镜像
- [ ] 可以安装包到虚拟环境
- [ ] 可以激活/停用虚拟环境

### 多架构支持（CI 环境）

- [ ] amd64 架构构建成功
- [ ] arm64 架构构建成功
- [ ] 镜像可以同时在两种架构运行

### 文档

- [ ] README 更新完整
- [ ] CLI_TOOLS_GUIDE 更新完整
- [ ] 示例命令可以执行
- [ ] 故障排查说明有效

## 提交问题

如果测试过程中遇到问题，请提交 Issue 包含以下信息：

1. Docker 版本 (`docker --version`)
2. Dockerfile 版本（commit 哈希）
3. 操作系统和架构
4. 完整的错误日志
5. 复现步骤

## 持续集成

GitHub Actions 会自动在每次 push 时运行测试。你可以查看：

- 构建状态：https://github.com/hiext/base-images/actions
- 容器镜像：https://github.com/hiext/base-images/pkgs/container/openclaw
