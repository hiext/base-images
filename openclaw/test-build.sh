#!/usr/bin/env bash
#
# OpenClaw 镜像构建和测试脚本
#
# 用法: ./test-build.sh [镜像名]
#

set -eo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 测试镜像名称
IMAGE_NAME="${1:-openclaw:test}"
VARIANT="${2:-default}"
DATE=$(date '+%Y%m%d_%H%M%S')
TEST_RESULTS="test-results-${DATE}.log"

# 检查 Docker 是否可用
check_docker() {
 echo "========================================"
 echo "检查 Docker 环境"
 echo "========================================"

 if ! command -v docker &> /dev/null; then
 echo -e "${RED}✗ Docker 未安装${NC}"
 exit 1
 fi

 if ! docker info &> /dev/null; then
 echo -e "${RED}✗ Docker Daemon 未运行${NC}"
 exit 1
 fi

 local docker_version=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
 echo -e "${GREEN}✓ Docker 版本: ${docker_version}${NC}"
 echo ""
}

# 构建镜像
build_image() {
 echo "========================================"
 echo "构建测试镜像: ${IMAGE_NAME}"
 echo "========================================"

 local start_time=$(date +%s)

 if docker build -t "${IMAGE_NAME}" .; then
 local end_time=$(date +%s)
 local build_time=$((end_time - start_time))
 echo -e "${GREEN}✓ 构建成功 (${build_time}s)${NC}"
 echo "BUILD_SUCCESS=true" >> "${TEST_RESULTS}"
 else
 echo -e "${RED}✗ 构建失败${NC}"
 echo "BUILD_SUCCESS=false" >> "${TEST_RESULTS}"
 return 1
 fi
 echo ""
}

# 测试 pip 镜像源
test_pip_mirror() {
 echo "========================================"
 echo "测试 pip 镜像源配置"
 echo "========================================"

 local index_url
 index_url=$(docker run --rm "${IMAGE_NAME}" pip3 config get global.index-url 2>&1)

 if [[ "$index_url" == "https://pypi.tuna.tsinghua.edu.cn/simple" ]]; then
 echo -e "${GREEN}✓ pip 镜像源已配置为清华大学 TUNA${NC}"
 echo "  URL: ${index_url}"
 echo "PIP_MIRROR_SUCCESS=true" >> "${TEST_RESULTS}"
 else
 echo -e "${YELLOW}! pip 镜像源未配置${NC}"
 echo "  当前: ${index_url}"
 echo "PIP_MIRROR_SUCCESS=false" >> "${TEST_RESULTS}"
 fi
 echo ""
}

# 测试 npm 镜像源
test_npm_mirror() {
 echo "========================================"
 echo "测试 npm 镜像源配置"
 echo "========================================"

 local registry
 registry=$(docker run --rm "${IMAGE_NAME}" npm config get registry 2>&1)

 if [[ "$registry" == "https://registry.npmmirror.com/" ]] || [[ "$registry" == "https://registry.npmmirror.com" ]]; then
 echo -e "${GREEN}✓ npm 镜像源已配置为淘宝镜像${NC}"
 echo "  URL: ${registry}"
 echo "NPM_MIRROR_SUCCESS=true" >> "${TEST_RESULTS}"
 else
 echo -e "${YELLOW}! npm 镜像源未配置${NC}"
 echo "  当前: ${registry}"
 echo "NPM_MIRROR_SUCCESS=false" >> "${TEST_RESULTS}"
 fi
 echo ""
}

# 测试 Python 虚拟环境
test_python_venv() {
 echo "========================================"
 echo "测试 Python 虚拟环境"
 echo "========================================"

 # 测试 venv 模块
 if docker run --rm "${IMAGE_NAME}" python3 -m venv --help > /dev/null 2>&1; then
 echo -e "${GREEN}✓ python3-venv 已安装${NC}"
 echo "PYTHON_VENV_INSTALLED=true" >> "${TEST_RESULTS}"
 else
 echo -e "${RED}✗ python3-venv 未安装${NC}"
 echo "PYTHON_VENV_INSTALLED=false" >> "${TEST_RESULTS}"
 return 1
 fi

 # 测试创建虚拟环境
 if docker run --rm "${IMAGE_NAME}" bash -c "python3 -m venv /tmp/test-venv && test -d /tmp/test-venv/bin" > /dev/null 2>&1; then
 echo -e "${GREEN}✓ 虚拟环境创建成功${NC}"
 echo "PYTHON_VENV_WORKS=true" >> "${TEST_RESULTS}"
 else
 echo -e "${RED}✗ 虚拟环境创建失败${NC}"
 echo "PYTHON_VENV_WORKS=false" >> "${TEST_RESULTS}"
 return 1
 fi
 echo ""
}

# 测试 pip 安装（可选，需要联网）
test_pip_install() {
 echo "========================================"
 echo "测试 pip 安装（联网测试）"
 echo "========================================"

 if docker run --rm "${IMAGE_NAME}" pip3 install --dry-run requests > /dev/null 2>&1; then
 echo -e "${GREEN}✓ pip 安装测试成功${NC}"
 echo "PIP_INSTALL_SUCCESS=true" >> "${TEST_RESULTS}"
 else
 echo -e "${YELLOW}! pip 安装测试失败（可能需要联网）${NC}"
 echo "PIP_INSTALL_SUCCESS=false" >> "${TEST_RESULTS}"
 fi
 echo ""
}

# 测试 npm 安装（可选，需要联网）
test_npm_install() {
 echo "========================================"
 echo "测试 npm 安装（联网测试）"
 echo "========================================"

 if docker run --rm "${IMAGE_NAME}" npm install --dry-run lodash > /dev/null 2>&1; then
 echo -e "${GREEN}✓ npm 安装测试成功${NC}"
 echo "NPM_INSTALL_SUCCESS=true" >> "${TEST_RESULTS}"
 else
 echo -e "${YELLOW}! npm 安装测试失败（可能需要联网）${NC}"
 echo "NPM_INSTALL_SUCCESS=false" >> "${TEST_RESULTS}"
 fi
 echo ""
}

# 测试 FFmpeg
test_ffmpeg() {
 echo "========================================"
 echo "测试 FFmpeg 安装"
 echo "========================================"

 if docker run --rm "${IMAGE_NAME}" ffmpeg -version > /dev/null 2>&1; then
 local version
 version=$(docker run --rm "${IMAGE_NAME}" ffmpeg -version | head -1 | cut -d' ' -f3)
 echo -e "${GREEN}✓ FFmpeg 已安装${NC}"
 echo "  版本: ${version}"
 echo "FFMPEG_INSTALLED=true" >> "${TEST_RESULTS}"
 else
 echo -e "${RED}✗ FFmpeg 未安装${NC}"
 echo "FFMPEG_INSTALLED=false" >> "${TEST_RESULTS}"
 fi
 echo ""
}

# 测试 OpenClaw 功能
test_openclaw() {
 echo "========================================"
 echo "测试 OpenClaw 安装"
 echo "========================================"

 if docker run --rm "${IMAGE_NAME}" which node > /dev/null 2>&1; then
 local node_version
 node_version=$(docker run --rm "${IMAGE_NAME}" node --version)
 echo -e "${GREEN}✓ Node.js 已安装${NC}"
 echo "  版本: ${node_version}"
 echo "NODE_INSTALLED=true" >> "${TEST_RESULTS}"
 else
 echo -e "${RED}✗ Node.js 未安装${NC}"
 echo "NODE_INSTALLED=false" >> "${TEST_RESULTS}"
 fi
 echo ""
}

# 显示测试结果摘要
show_summary() {
 echo "========================================"
 echo "测试结果摘要"
 echo "========================================"

 local passed=0
 local failed=0

 while IFS='=' read -r key value; do
 if [[ "$value" == "true" ]]; then
 echo -e "${GREEN}✓ ${key}${NC}"
 ((passed++))
 elif [[ "$value" == "false" ]]; then
 echo -e "${RED}✗ ${key}${NC}"
 ((failed++))
 fi
 done < "${TEST_RESULTS}"

 echo ""
 echo "通过: ${passed}, 失败: ${failed}"
 echo "详细结果保存到: ${TEST_RESULTS}"

 if [[ $failed -eq 0 ]]; then
 echo -e "${GREEN}\n✓ 所有测试通过！${NC}"
 return 0
 else
 echo -e "${YELLOW}\n! 部分测试失败，请检查输出${NC}"
 return 1
 fi
}

# 清理测试容器
cleanup() {
 echo ""
 echo "========================================"
 echo "正在清理..."
 echo "========================================"
 docker container prune -f --filter "label=test=openclaw" > /dev/null 2>&1 || true
 echo "清理完成"
}

# 主函数
main() {
 echo "OpenClaw 镜像测试脚本"
 echo "====================="
 echo ""

 # 清理旧的结果文件
 rm -f "${TEST_RESULTS}"

 # 执行测试
 check_docker
 build_image || { echo "构建失败，退出测试"; exit 1; }
 test_pip_mirror
 test_npm_mirror
 test_python_venv
 test_pip_install
 test_npm_install
 test_ffmpeg
 test_openclaw
 show_summary

 # 提示用户
 echo ""
 echo "========================================"
 echo "后续步骤"
 echo "========================================"
 echo ""
 echo "1. 推送镜像到仓库（可选）:"
 echo "   docker tag ${IMAGE_NAME} ghcr.io/username/openclaw:test"
 echo "   docker push ghcr.io/username/openclaw:test"
 echo ""
 echo "2. 运行容器进行手动测试:"
 echo "   docker run -d -p 18789:18789 --name openclaw-test ${IMAGE_NAME}"
 echo ""
 echo "3. 查看日志:"
 echo "   docker logs openclaw-test"
 echo ""

 # 清理
 trap cleanup EXIT
}

# 执行主函数
main "$@"
