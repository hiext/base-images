# base-images 项目文档

> 最后更新：2026-03-19 10:30:45

## 变更记录 (Changelog)

### 2026-03-19
- 初始化项目 AI 上下文
- 生成根级 CLAUDE.md
- 生成 postgres 模块 CLAUDE.md
- 建立 .claude/index.json 索引

---

## 项目愿景

base-images 是一个基础 Docker 镜像仓库，用于构建和维护 Immich 项目所需的自定义 PostgreSQL 数据库镜像。该仓库提供预配置的 PostgreSQL 镜像，集成了向量搜索扩展（pgvector、VectorChord、pgvecto.rs），专为机器学习和 AI 应用场景优化。

---

## 架构总览

本项目采用 Docker 容器化架构，通过 GitHub Actions 实现自动化构建和多平台支持（amd64/arm64）。核心架构包括：

1. **镜像构建层**：基于官方 pgvector/pgvector 镜像，叠加 VectorChord 和 pgvecto.rs 扩展
2. **配置管理层**：提供 HDD/SSD 两种存储优化的 PostgreSQL 配置模板
3. **CI/CD 层**：GitHub Actions 工作流自动构建和发布到 GitHub Container Registry

---

## 模块结构图

```mermaid
graph TD
    A["(根) base-images"] --> B["postgres"]
    A --> C[".github"]
    C --> D["workflows"]
    A --> E[".spec-workflow"]

    click B "./postgres/CLAUDE.md" "查看 postgres 模块文档"
```

---

## 模块索引

| 模块路径 | 职责描述 | 语言/技术 | 入口文件 |
|---------|---------|----------|---------|
| [postgres](./postgres/CLAUDE.md) | PostgreSQL 基础镜像构建，集成向量搜索扩展 | Dockerfile, Shell | Dockerfile |

---

## 运行与开发

### 本地构建

```bash
# 进入 postgres 目录
cd postgres

# 构建镜像（示例）
docker build . \
  --build-arg="PG_MAJOR=17" \
  --build-arg="PGVECTOR_TAG=0.8.0" \
  --build-arg="VECTORCHORD_TAG=0.3.0" \
  --build-arg="PGVECTORS_TAG=0.3.0"
```

### 本地运行（使用 docker-compose）

```bash
cd postgres
docker-compose up -d
```

### 版本矩阵

支持的版本组合定义在 `postgres/versions.yaml` 中：
- PostgreSQL：14, 15, 16, 17, 18
- VectorChord：0.5.3
- pgvector：0.8.1

---

## 测试策略

当前项目以镜像构建为主，测试策略包括：
1. **构建验证**：GitHub Actions 自动构建验证
2. **健康检查**：内置 healthcheck.sh 脚本
3. **数据完整性**：checksum 失败检测

---

## 编码规范

1. **Shell 脚本**：使用 `#!/usr/bin/env bash` shebang，启用 `set -eo pipefail`
2. **Dockerfile**：多阶段构建，清理缓存减少镜像体积
3. **配置文件**：使用模板变量，支持运行时替换

---

## AI 使用指引

### 适合 AI 辅助的任务

1. 添加新的 PostgreSQL 版本支持
2. 更新扩展版本（pgvector、VectorChord）
3. 优化配置参数
4. 编写构建脚本和自动化工具

### 需要注意的事项

1. 修改 Dockerfile 时注意多架构兼容性（amd64/arm64）
2. 版本更新需同步更新 `versions.yaml` 和 CI 工作流
3. 配置文件修改需考虑 HDD/SSD 两种场景
4. Secrets 文件不应提交到版本控制

### 推荐的 AI 工作流

1. 添加新版本：修改 versions.yaml -> 验证构建参数 -> 测试镜像
2. 优化配置：分析性能需求 -> 调整 postgresql.conf 模板 -> 测试验证
3. 扩展功能：评估依赖 -> 更新 Dockerfile -> 验证安装脚本

---

## 相关资源

- [pgvector 官方仓库](https://github.com/pgvector/pgvector)
- [VectorChord 官方仓库](https://github.com/tensorchord/VectorChord)
- [pgvecto.rs 官方仓库](https://github.com/tensorchord/pgvecto.rs)
- [PostgreSQL 官方文档](https://www.postgresql.org/docs/)
