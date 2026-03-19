[根目录](../CLAUDE.md) > **postgres**

---

# postgres 模块文档

> 最后更新：2026-03-19 10:30:45

## 变更记录 (Changelog)

### 2026-03-19
- 初始化模块文档
- 完成文件清单与接口梳理

---

## 模块职责

postgres 模块负责构建集成向量搜索扩展的自定义 PostgreSQL Docker 镜像，为 Immich 应用提供高性能的向量数据库支持。主要功能包括：

1. 集成 pgvector、VectorChord、pgvecto.rs 三种向量扩展
2. 提供 HDD/SSD 存储优化配置
3. 支持多 PostgreSQL 版本（14-18）
4. 提供健康检查和数据完整性验证

---

## 入口与启动

### Dockerfile 构建入口

**文件**：`Dockerfile`

**构建参数**：
- `PG_MAJOR`：PostgreSQL 主版本号（如 16、17）
- `PGVECTOR_TAG`：pgvector 扩展版本（如 0.8.0）
- `VECTORCHORD_TAG`：VectorChord 扩展版本（如 0.3.0）
- `PGVECTORS_TAG`：pgvecto.rs 扩展版本（可选，如 0.3.0）
- `TARGETARCH`：目标架构（amd64/arm64）

**基础镜像**：`pgvector/pgvector:${PGVECTOR_TAG}-pg${PG_MAJOR}`

**入口脚本**：
- `/usr/local/bin/immich-docker-entrypoint.sh`：容器启动入口
- `/usr/local/bin/healthcheck.sh`：健康检查脚本
- `/usr/local/bin/set-env.sh`：环境变量设置脚本

### docker-compose 本地启动

**文件**：`docker-compose.yml`

**配置要点**：
- 使用非 root 用户运行（1000:1001）
- 通过 secrets 管理敏感信息
- 挂载本地 `./data` 目录持久化数据

**启动命令**：
```bash
docker-compose up -d
```

---

## 对外接口

### 环境变量

| 变量名 | 描述 | 示例值 |
|-------|------|--------|
| `DB_STORAGE_TYPE` | 存储类型（SSD/HDD） | `SSD` |
| `POSTGRES_PASSWORD_FILE` | 密码文件路径 | `/run/secrets/immich_db_password` |
| `DB_USERNAME_FILE` | 用户名文件路径 | `/run/secrets/immich_db_user` |
| `DB_DATABASE_NAME` | 数据库名称 | `database_name` |
| `POSTGRES_INITDB_ARGS` | 初始化参数 | `--data-checksums` |
| `PGDATA` | 数据目录 | `/var/lib/postgresql/data/pgdata` |

### Secrets 配置

需在 `secrets/` 目录下准备：
- `postgres_username.txt`：数据库用户名
- `postgres_password.txt`：数据库密码

### 健康检查接口

健康检查脚本执行以下验证：
1. 数据库连接检查：`pg_isready`
2. 数据完整性检查：checksum 失败计数

**健康检查配置**：
- 间隔：5 分钟
- 启动间隔：5 秒
- 启动期：5 分钟

---

## 关键依赖与配置

### 扩展依赖

| 扩展名称 | 来源 | 用途 |
|---------|------|------|
| pgvector | pgvector/pgvector 基础镜像 | 向量相似度搜索 |
| VectorChord | tensorchord/VectorChord releases | 高性能向量索引 |
| pgvecto.rs | tensorchord/pgvecto.rs releases（可选） | Rust 实现向量搜索 |

### 配置文件

| 文件 | 用途 | 关键参数 |
|-----|------|---------|
| `postgresql.ssd.conf` | SSD 存储优化配置 | `effective_io_concurrency=200`, `random_page_cost=1.2` |
| `postgresql.hdd.conf` | HDD 存储优化配置 | 默认 IO 参数 |
| `versions.yaml` | 版本矩阵定义 | pg: 14-18, vectorchord: 0.5.3, pgvector: 0.8.1 |

### 通用配置参数

两种存储类型共享的优化参数：
- `shared_preload_libraries = 'vchord.so'`
- `max_wal_size = 5GB`
- `shared_buffers = 512MB`
- `wal_compression = on`
- `work_mem = 16MB`
- `autovacuum_vacuum_scale_factor = 0.1`

---

## 数据模型

本模块为基础设施组件，不定义应用数据模型。PostgreSQL 启动后由应用层创建表结构。

---

## 测试与质量

### 构建验证

- **CI/CD**：GitHub Actions 自动构建（`.github/workflows/build-postgres.yml`）
- **多平台支持**：linux/amd64, linux/arm64
- **缓存策略**：使用 GitHub Actions 缓存加速构建

### 运行时验证

**healthcheck.sh** 执行：
```bash
# 数据库连接检查
pg_isready --dbname="${POSTGRES_DB}" --username="${POSTGRES_USER}"

# 数据完整性检查
psql --command='SELECT COALESCE(SUM(checksum_failures), 0) FROM pg_stat_database'
```

### 版本矩阵测试

CI 自动对所有版本组合进行构建测试：
- PostgreSQL 版本：14, 15, 16, 17, 18
- 扩展版本组合矩阵

---

## 常见问题 (FAQ)

### Q1: 如何切换存储类型？

修改环境变量 `DB_STORAGE_TYPE`：
- `SSD`：适合 SSD 存储，优化随机 IO
- `HDD`：适合 HDD 存储，保守配置

### Q2: 如何添加新的 PostgreSQL 版本？

1. 编辑 `versions.yaml`，在 `pg` 列表中添加版本号
2. 验证基础镜像 `pgvector/pgvector` 是否支持该版本
3. 提交更改，CI 自动构建新版本

### Q3: pgvecto.rs 扩展是否必需？

不是必需。pgvecto.rs 为可选扩展，可通过 `PGVECTORS_TAG` 参数控制。如果不需要，可以不传递该参数。

### Q4: 如何自定义 PostgreSQL 配置？

方式一：修改 `postgresql.ssd.conf` 或 `postgresql.hdd.conf` 模板
方式二：挂载自定义配置到 `$PGDATA/postgresql.override.conf`

### Q5: 数据持久化如何处理？

默认挂载 `./data` 目录到容器内。生产环境建议：
- 使用命名卷或外部存储
- 配置备份策略
- 监控磁盘使用

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
| `immich-docker-entrypoint.sh` | 容器入口脚本，处理存储类型选择 |
| `healthcheck.sh` | 健康检查脚本 |
| `set-env.sh` | 环境变量处理，支持文件和直接值 |

### 配置文件

| 文件 | 描述 |
|-----|------|
| `postgresql.ssd.conf` | SSD 存储优化配置模板 |
| `postgresql.hdd.conf` | HDD 存储优化配置模板 |

### Secrets

| 文件 | 描述 |
|-----|------|
| `secrets/postgres_username.txt` | 数据库用户名 |
| `secrets/postgres_password.txt` | 数据库密码 |

---

## 扩展阅读

- [PostgreSQL 性能优化指南](https://www.postgresql.org/docs/current/performance-tips.html)
- [pgvector 文档](https://github.com/pgvector/pgvector#readme)
- [VectorChord 文档](https://github.com/tensorchord/VectorChord#readme)
