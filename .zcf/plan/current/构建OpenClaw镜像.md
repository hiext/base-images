# OpenClaw 镜像构建执行计划

## 任务描述

为 base-images 项目添加 openclaw 模块，构建集成 Python、FFmpeg、FFprobe 的自定义 OpenClaw 镜像，支持多基础镜像（Ubuntu、Debian）并自动跟踪最新版本。

## 项目信息

- **项目**：base-images
- **模块**：openclaw
- **方案**：混合方案 - 使用官方构建产物
- **开始时间**：2026-03-19

## 需求总结

### OpenClaw 项目概述
- **项目类型**：个人 AI 助手平台
- **官方仓库**：https://github.com/openclaw/openclaw
- **技术栈**：Node.js ≥22，TypeScript
- **最新版本**：v2026.3.13-1（2026-03-14）
- **许可证**：MIT

### 镜像定制需求
1. ✅ 安装 OpenClaw 核心组件
2. ✅ 自动跟踪上游最新发布版本
3. ✅ 预装 Python 3.x
4. ✅ 预装 FFmpeg / FFprobe
5. ✅ 多基础镜像支持（Ubuntu 24.04/22.04、Debian Bookworm）
6. ✅ 配置文件和启动脚本
7. ✅ 健康检查机制
8. ✅ GitHub Actions 自动构建和推送

## 技术架构

### 核心思路
- 使用 OpenClaw 官方预构建产物（npm 包）
- 在多个基础镜像中独立安装
- 通过 GitHub Actions 自动跟踪最新版本
- 预装 Python、FFmpeg、FFprobe 等工具

### 技术栈
- 基础镜像：Ubuntu 24.04/22.04、Debian Bookworm
- 运行时：Node.js 24.x
- 工具：Python 3.x、FFmpeg（最新版）
- CI/CD：GitHub Actions + Docker Buildx

## 文件结构

```
openclaw/
├── Dockerfile                          # 主构建文件（Ubuntu 24.04）
├── Dockerfile.ubuntu22                 # Ubuntu 22.04 变体
├── Dockerfile.debian                   # Debian Bookworm 变体
├── versions.yaml                       # 版本矩阵配置
├── docker-compose.yml                  # 本地开发配置
├── .dockerignore                       # Docker 忽略文件
├── scripts/
│   ├── entrypoint.sh                   # 容器启动入口脚本
│   ├── healthcheck.sh                  # 健康检查脚本
│   ├── download-latest.sh              # 下载最新版本脚本
│   └── install-tools.sh                # 工具安装脚本
├── config/
│   └── openclaw.default.conf           # 默认配置文件
└── README.md                           # 模块文档
```

## 执行阶段

### 阶段 1：创建 openclaw 模块目录结构
- [ ] 创建模块根目录和子目录
- [ ] 创建 versions.yaml 版本配置文件

### 阶段 2：编写 Dockerfile 文件
- [ ] 创建主 Dockerfile（Ubuntu 24.04）
- [ ] 创建 Ubuntu 22.04 变体 Dockerfile
- [ ] 创建 Debian Bookworm 变体 Dockerfile

### 阶段 3：编写脚本文件
- [ ] 创建 entrypoint.sh 启动脚本
- [ ] 创建 healthcheck.sh 健康检查脚本
- [ ] 创建 download-latest.sh 版本下载脚本
- [ ] 创建 install-tools.sh 工具安装脚本

### 阶段 4：创建配置文件
- [ ] 创建 openclaw.default.conf 默认配置
- [ ] 创建 docker-compose.yml 本地开发配置

### 阶段 5：创建 GitHub Actions 工作流
- [ ] 创建 build-openclaw.yml 构建工作流

### 阶段 6：更新项目文档
- [ ] 创建 openclaw/README.md
- [ ] 创建 openclaw/CLAUDE.md
- [ ] 更新根级 CLAUDE.md

### 阶段 7：测试和验证
- [ ] 本地构建测试
- [ ] 功能验证
- [ ] 验证预装工具

## 当前进度

状态：执行中
当前阶段：阶段 1 - 创建目录结构