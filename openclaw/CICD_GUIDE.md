# CI/CD 工作流详细说明

> 📖 GitHub Actions 自动化构建和部署指南
>
> 最后更新：2026-03-20

---

## 📋 工作流概览

**工作流文件**：`.github/workflows/build-openclaw.yml`

**触发条件**：
1. ✅ 推送到 `main` 分支（`openclaw/` 目录变更）
2. ✅ 每周自动执行（检查版本更新）
3. ✅ 手动触发（workflow_dispatch）
4. ✅ Pull Request（仅构建测试）

**支持的基础镜像**：
- Ubuntu 24.04（默认）
- Ubuntu 22.04 LTS
- Debian 12 (Bookworm)

**构建架构**：
- linux/amd64
- linux/arm64

---

## 🔄 工作流程详解

### Job 1: check-version

**职责**：检查 OpenClaw 最新版本

**步骤**：
1. 从 GitHub API 获取最新发布版本
2. 提取版本号（去掉 `v` 前缀）
3. 与当前 `versions.yaml` 对比
4. 输出版本变化状态

**输出**：
- `version`: 最新版本号（如 `2026.3.13`）
- `changed`: 是否有版本更新（`true`/`false`）

**示例**：
```yaml
outputs:
  version: "2026.3.13"
  changed: "true"
```

---

### Job 2: update-version

**职责**：自动更新版本配置

**触发条件**：
- `check-version` 输出 `changed=true`
- 不是 Pull Request

**步骤**：
1. 检出代码
2. 使用 `yq` 更新 `versions.yaml`
3. 提交并推送更改

**提交信息**：
```
chore: update OpenClaw to 2026.3.13
```

---

### Job 3: matrix

**职责**：生成构建矩阵

**步骤**：
1. 读取 `openclaw/versions.yaml`
2. 转换为 JSON 格式
3. 输出矩阵配置

**输出示例**：
```json
{
  "openclaw": ["latest"],
  "base_images": [
    {"name": "ubuntu", "tag": "24.04", "node_version": "24"},
    {"name": "ubuntu", "tag": "22.04", "node_version": "22"},
    {"name": "debian", "tag": "bookworm", "node_version": "24"}
  ]
}
```

---

### Job 4: build-and-push

**职责**：构建并推送镜像

**触发条件**：
- `check-version` 成功或跳过
- 矩阵配置就绪

**并行策略**：
- 同时构建所有基础镜像变体
- `fail-fast: false`（单个失败不影响其他构建）

**步骤详解**：

#### 4.1 环境准备

```yaml
- Set up QEMU          # 多架构支持
- Set up Docker Buildx # 构建工具
- Login to GHCR        # 容器仓库认证
```

#### 4.2 构建决策

**推送条件**：
- ✅ 手动触发（`workflow_dispatch`）
- ✅ 版本更新（`changed=true`）
- ✅ 推送到 main 分支（非 PR）
- ❌ Pull Request（仅测试构建）

#### 4.3 镜像标签生成

**标签策略**：

| 基础镜像 | 标签示例 |
|---------|---------|
| Ubuntu 24.04 | `2026.3.13`, `latest` |
| Ubuntu 22.04 | `2026.3.13-ubuntu22`, `latest-ubuntu22` |
| Debian | `2026.3.13-debian`, `latest-debian` |

**完整标签格式**：
```
ghcr.io/hiext/openclaw:2026.3.13
ghcr.io/hiext/openclaw:latest
ghcr.io/hiext/openclaw:2026.3.13-ubuntu22
ghcr.io/hiext/openclaw:latest-ubuntu22
ghcr.io/hiext/openclaw:2026.3.13-debian
ghcr.io/hiext/openclaw:latest-debian
```

#### 4.4 构建执行

**构建参数**：
```yaml
build-args: |
  OPENCLAW_VERSION=2026.3.13
  BASE_IMAGE=ubuntu:24.04
  NODE_VERSION=24
```

**缓存策略**：
```yaml
cache-from: type=gha  # GitHub Actions 缓存
cache-to: type=gha,mode=max
```

**平台支持**：
```yaml
platforms: linux/amd64,linux/arm64
```

---

### Job 5: results

**职责**：汇总构建结果

**触发条件**：`always()`（无论成功或失败）

**步骤**：
- 检查 `build-and-push` 的结果
- 输出成功或失败状态
- 设置退出码

**状态判断**：
```bash
if [[ $result == "success" || $result == "skipped" ]]; then
  exit 0  # 成功
else
  exit 1  # 失败
fi
```

---

## 🎯 触发场景详解

### 场景 1: 日常开发推送

**触发方式**：
```bash
git add openclaw/README.md
git commit -m "docs: update README"
git push origin main
```

**工作流行为**：
1. ✅ 触发 `check-version`
2. ⏭️ 如果版本未变，跳过 `update-version`
3. ✅ 执行 `matrix` 和 `build-and-push`
4. ✅ 构建所有变体并推送到 GHCR

**预计耗时**：15-25 分钟

---

### 场景 2: OpenClaw 新版本发布

**自动检测流程**：

```
每周日 00:00 UTC
    ↓
检查 GitHub API
    ↓
发现新版本: 2026.3.14
    ↓
更新 versions.yaml
    ↓
自动提交
    ↓
触发构建流程
    ↓
推送到 GHCR
```

**手动触发检查**：
```bash
gh workflow run build-openclaw.yml
```

---

### 场景 3: Pull Request

**触发方式**：
```bash
git checkout -b feature/update-config
# 修改文件
git push origin feature/update-config
gh pr create
```

**工作流行为**：
1. ✅ 执行所有检查和构建步骤
2. ❌ **不会推送镜像到 GHCR**
3. ✅ 提供构建状态检查（PR 状态）

**目的**：验证 PR 不会破坏构建流程

---

### 场景 4: 手动触发

**方式 1: GitHub Web UI**

1. 访问：https://github.com/hiext/base-images/actions
2. 选择：Build and Push OpenClaw Images
3. 点击：Run workflow
4. 确认执行

**方式 2: GitHub CLI**

```bash
gh workflow run build-openclaw.yml
```

**方式 3: API 调用**

```bash
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/hiext/base-images/actions/workflows/build-openclaw.yml/dispatches \
  -d '{"ref":"main"}'
```

**工作流行为**：
- ✅ 强制执行完整构建
- ✅ 推送所有镜像到 GHCR
- ⚠️ 即使版本未变也会推送

---

## 📊 监控和日志

### 查看工作流运行

**Web UI**：
```
https://github.com/hiext/base-images/actions/workflows/build-openclaw.yml
```

**GitHub CLI**：
```bash
# 列出最近运行
gh run list --workflow=build-openclaw.yml --limit 10

# 查看特定运行
gh run view RUN_ID

# 实时日志
gh run watch RUN_ID
```

### 关键日志点

**构建日志包含**：
1. ✅ 版本检查结果
2. ✅ 基础镜像选择
3. ✅ 多架构构建进度
4. ✅ 镜像推送状态
5. ✅ 最终镜像摘要

**示例输出**：
```
✓ check-version: Latest version: 2026.3.13
✓ build-and-push (ubuntu:24.04): Built successfully
  Digest: sha256:abc123...
  Tags: ghcr.io/hiext/openclaw:2026.3.13, ghcr.io/hiext/openclaw:latest
✓ build-and-push (ubuntu:22.04): Built successfully
  Tags: ghcr.io/hiext/openclaw:2026.3.13-ubuntu22
✓ build-and-push (debian:bookworm): Built successfully
  Tags: ghcr.io/hiext/openclaw:2026.3.13-debian
```

---

## ⚙️ 自定义配置

### 修改构建矩阵

**编辑 `versions.yaml`**：

```yaml
base_images:
  # 添加新的基础镜像
  - name: ubuntu
    tag: "20.04"
    node_version: "20"
    description: "Ubuntu 20.04 LTS"
```

**效果**：下次构建会自动包含 Ubuntu 20.04 变体

---

### 修改定时任务

**编辑工作流文件**：

```yaml
on:
  schedule:
    - cron: '0 0 * * 0'  # 每周日 00:00 UTC
```

**修改为每天检查**：
```yaml
  schedule:
    - cron: '0 0 * * *'  # 每天 00:00 UTC
```

---

### 添加新的构建参数

**编辑 Dockerfile**：

```dockerfile
ARG CUSTOM_ARG=default
```

**更新工作流**：

```yaml
build-args: |
  OPENCLAW_VERSION=${{ needs.check-version.outputs.version }}
  BASE_IMAGE=${{ matrix.base_image.name }}:${{ matrix.base_image.tag }}
  NODE_VERSION=${{ matrix.base_image.node_version }}
  CUSTOM_ARG=${{ vars.CUSTOM_ARG }}  # 使用仓库变量
```

---

## 🔐 权限和密钥

### 所需权限

```yaml
permissions:
  packages: write    # 推送到 GHCR
  contents: read     # 检出代码
```

### 使用密钥

**设置密钥**：
1. 进入仓库 Settings → Secrets and variables → Actions
2. 添加 `GITHUB_TOKEN`（自动提供）
3. 添加自定义密钥

**在工作流中使用**：

```yaml
- name: Login to GHCR
  uses: docker/login-action@v4
  with:
    registry: ghcr.io
    username: ${{ github.repository_owner }}
    password: ${{ secrets.GITHUB_TOKEN }}
```

---

## 🐛 常见问题

### Q1: 构建超时怎么办？

**症状**：
```
Error: The job running on runner GitHub Actions 2 has exceeded the maximum execution time of 6 hours.
```

**解决方案**：

1. **优化 Dockerfile**：
```dockerfile
# 使用缓存挂载
RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update && apt-get install -y ...
```

2. **分割构建任务**：
```yaml
strategy:
  max-parallel: 2  # 减少并行构建数
```

---

### Q2: 多架构构建失败？

**症状**：
```
ERROR: executor failed running [...]: exec format error
```

**解决方案**：

```bash
# 重新安装 QEMU
docker run --privileged --rm tonistiigi/binfmt --install all

# 验证
docker buildx ls
```

---

### Q3: 推送镜像失败？

**症状**：
```
denied: permission_denied
```

**解决方案**：

1. **检查权限**：
```yaml
permissions:
  packages: write
```

2. **验证令牌**：
```bash
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
```

---

## 📈 优化建议

### 1. 启用构建缓存

**使用 GitHub Actions 缓存**：

```yaml
- name: Set up Docker Buildx
  uses: docker/setup-buildx-action@v4

- name: Cache Docker layers
  uses: actions/cache@v4
  with:
    path: /tmp/.buildx-cache
    key: ${{ runner.os }}-buildx-${{ github.sha }}
    restore-keys: |
      ${{ runner.os }}-buildx-
```

---

### 2. 使用矩阵优化

**并行构建多个配置**：

```yaml
strategy:
  matrix:
    base_image: [ubuntu:24.04, ubuntu:22.04, debian:bookworm]
  max-parallel: 3
```

---

### 3. 条件执行

**仅在特定文件变更时构建**：

```yaml
on:
  push:
    paths:
      - 'openclaw/**'
      - '.github/workflows/build-openclaw.yml'
```

---

## 📚 相关文档

- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [Docker Buildx 文档](https://docs.docker.com/buildx/working-with-buildx/)
- [GHCR 文档](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)

---

**文档版本**: v1.0
**最后更新**: 2026-03-20