# OpenClaw 工具使用指南

本镜像预装了 Python 3、Node.js/npm、FFmpeg 等常用工具，并配置了国内镜像加速。

## 📋 快速参考

```bash
# Python 虚拟环境
docker exec -it openclaw bash -c "python3 -m venv venv && source venv/bin/activate"

# pip 安装（自动使用清华镜像）
docker exec openclaw pip3 install requests

# npm 安装（自动使用淘宝镜像）
docker exec openclaw npm install lodash

# FFmpeg
docker exec openclaw ffmpeg -i input.mp4 output.mp4
```

---

## 🐍 Python 使用指南

### 版本信息

```bash
docker exec openclaw python3 --version
docker exec openclaw pip3 --version
```

### pip 国内镜像配置

本镜像已自动配置清华大学 TUNA 镜像源，无需手动设置。

**验证配置：**
```bash
docker exec openclaw pip3 config get global.index-url
# 输出：https://pypi.tuna.tsinghua.edu.cn/simple
```

**查看完整配置：**
```bash
docker exec openclaw pip3 config list
```

**如果需要临时使用官方源：**
```bash
docker exec openclaw pip3 install --index-url https://pypi.org/simple requests
```

**如果需要恢复官方源（可选）：**
```bash
docker exec openclaw pip3 config unset global.index-url
docker exec openclaw pip3 config unset install.trusted-host
```

### Python 虚拟环境

#### 创建虚拟环境

```bash
# 进入容器
docker exec -it openclaw bash

# 创建虚拟环境
cd /app/data
python3 -m venv myenv

# 激活虚拟环境
source myenv/bin/activate

# 退出虚拟环境
deactivate
```

#### 使用虚拟环境安装包

```bash
# 创建并激活虚拟环境
docker exec -it openclaw bash -c "cd /app/data && python3 -m venv myenv && source myenv/bin/activate && pip install requests pandas numpy"
```

### Python 使用示例

#### 示例 1：运行 Python 脚本

```bash
# 在容器中创建脚本
docker exec -it openclaw bash -c 'cat > /app/data/hello.py << EOF
#!/usr/bin/env python3
import sys
import requests

print(f"Python version: {sys.version}")
print(f"Requests version: {requests.__version__}")
EOF'

# 运行脚本
docker exec openclaw python3 /app/data/hello.py
```

#### 示例 2：使用 Jupyter Notebook

```bash
# 在虚拟环境中安装 Jupyter
source myenv/bin/activate
pip install jupyter

# 启动 Jupyter Notebook
jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root
```

#### 示例 3：常用 Python 库快速安装

```bash
# 数据科学
docker exec openclaw pip3 install numpy pandas matplotlib scipy

# Web 开发
docker exec openclaw pip3 install requests flask django

# AI/ML
docker exec openclaw pip3 install openai anthropic
```

---

## 📦 Node.js/npm 使用指南

### 版本信息

```bash
# 查看 Node.js 版本
docker exec openclaw node --version

# 查看 npm 版本
docker exec openclaw npm --version

# 查看 npm 配置
docker exec openclaw npm config get registry
# 输出：https://registry.npmmirror.com
```

### npm 国内镜像配置

本镜像已自动配置淘宝 npm 镜像，无需手动设置。

**验证配置：**
```bash
docker exec openclaw npm config get registry
```

**临时使用官方源：**
```bash
docker exec openclaw npm install lodash --registry https://registry.npmjs.org/
```

**恢复官方源（可选）：**
```bash
docker exec openclaw npm config set registry https://registry.npmjs.org/
```

### npm 全局包安装

**注意**：容器内部的全局包不会被持久化，建议使用本地安装或在 Data 目录下安装。

```bash
# 在 Data 目录下创建 node_modules 并设置 PATH
docker exec -it openclaw bash -c "cd /app/data && npm install -g typescript"

# 验证安装
docker exec openclaw which tsc
```

### npm 使用示例

#### 示例 1：安装常用工具

```bash
# 安装常用命令行工具
docker exec openclaw npm install -g \
 @types/node \
 typescript \
 ts-node
```

#### 示例 2：Node.js 脚本运行

```bash
# 创建 JavaScript 脚本
docker exec -it openclaw bash -c 'cat > /app/data/demo.js << EOF
const os = require("os");
const fs = require("fs");

console.log("Node.js version:", process.version);
console.log("Platform:", os.platform());
console.log("Architecture:", os.arch());
console.log("Home directory:", os.homedir());
EOF'

# 运行脚本
docker exec openclaw node /app/data/demo.js
```

#### 示例 3：创建简单 Node.js 项目

```bash
# 进入容器
docker exec -it openclaw bash

# 创建项目目录
mkdir -p /app/data/my-node-project
cd /app/data/my-node-project

# 初始化项目
npm init -y

# 安装依赖
npm install express axios

# 创建入口文件
cat > index.js << EOF
const express = require("express");
const app = express();

app.get("/", (req, res) => {
  res.json({ message: "Hello from OpenClaw!", timestamp: new Date() });
});

app.listen(3000, () => {
  console.log("Server running on port 3000");
});
EOF

# 运行
node index.js
```

---

## 🎬 FFmpeg 使用指南

### 版本信息

```bash
docker exec openclaw ffmpeg -version
docker exec openclaw ffprobe -version
```

### 常用命令

```bash
# 视频转码
docker exec openclaw ffmpeg -i input.mp4 -c:v libx264 -c:a aac output.mp4

# 提取音频
docker exec openclaw ffmpeg -i video.mp4 -vn -acodec copy audio.aac

# 视频截图
docker exec openclaw ffmpeg -i video.mp4 -ss 00:00:01 -vframes 1 thumbnail.jpg

# 查看媒体信息
docker exec openclaw ffprobe -v quiet -print_format json -show_streams input.mp4
```

---

## 🔧 Git 使用指南

```bash
# 配置 Git
docker exec openclaw git config --global user.name "Your Name"
docker exec openclaw git config --global user.email "your.email@example.com"

# 常用操作
docker exec openclaw git clone https://github.com/your/repo.git
docker exec openclaw git status
docker exec openclaw git commit -m "message"
```

---

## 📌 国内镜像源列表

### pip 镜像源

| 镜像源 | URL | 说明 |
|--------|-----|------|
| 清华大学 TUNA | https://pypi.tuna.tsinghua.edu.cn/simple | 本镜像默认使用 |
| 阿里云 | https://mirrors.aliyun.com/pypi/simple/ | 备用 |
| 中国科技大学 | https://pypi.mirrors.ustc.edu.cn/simple/ | 备用 |
| 豆瓣 | https://pypi.douban.com/simple/ | 备用 |

### npm 镜像源

| 镜像源 | URL | 说明 |
|--------|-----|------|
| 淘宝 NPM | https://registry.npmmirror.com | 本镜像默认使用 |
| 华为云 | https://mirrors.huaweicloud.com/repository/npm/ | 备用 |
| 腾讯云 | https://mirrors.cloud.tencent.com/npm/ | 备用 |
| 官方源 | https://registry.npmjs.org/ | 默认官方源 |

---

## 💡 最佳实践

### 1. 数据持久化

所有用户数据应放在 `/app/data` 目录：

```bash
# 创建项目目录
docker exec -it openclaw mkdir -p /app/data/my-project

# 使用 Docker Compose 持久化
volumes:
  - ./data:/app/data
```

### 2. Python 虚拟环境

建议在 `/app/data` 下创建虚拟环境：

```bash
cd /app/data
python3 -m venv myproject-venv
source myproject-venv/bin/activate
```

### 3. Node.js 项目

同样将项目放在 `/app/data`：

```bash
cd /app/data
mkdir my-node-app
cd my-node-app
npm init -y
```

### 4. 避免全局安装

全局包在容器重启后会丢失，建议：
- Python：使用虚拟环境
- Node.js：使用项目级别的 `--save` 安装

---

## ❓ 常见问题

### Q: pip 安装很慢？

A: 本镜像已配置清华镜像，如果仍然慢，可以尝试：

```bash
# 切换到阿里云镜像
docker exec openclaw pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple/
```

### Q: npm 安装失败？

A: 检查网络连接或尝试切换镜像源：

```bash
# 查看 npm 配置
docker exec openclaw npm config list

# 清除缓存
docker exec openclaw npm cache clean --force
```

### Q: 如何安装特定版本的 Python 包？

A:

```bash
docker exec openclaw pip3 install requests==2.28.1
```

### Q: 如何在容器外管理项目？

A: 使用 Docker Compose 挂载数据卷：

```yaml
volumes:
  - ./projects:/app/data/projects
```

然后在本地编辑，容器内运行。

---

## 相关文档

- [OpenClaw 文档](https://docs.openclaw.ai)
- [Python 官方文档](https://docs.python.org/3/)
- [npm 文档](https://docs.npmjs.com/)
- [FFmpeg 文档](https://ffmpeg.org/documentation.html)
