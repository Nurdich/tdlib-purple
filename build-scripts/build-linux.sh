#!/bin/bash
set -e

echo "开始编译 tdlib-purple for Linux..."

# 检查依赖
echo "检查依赖..."
if ! command -v cmake &> /dev/null; then
    echo "错误: cmake 未安装"
    exit 1
fi

if ! pkg-config --exists purple; then
    echo "错误: libpurple 开发包未安装"
    echo "Ubuntu/Debian: sudo apt install libpurple-dev"
    echo "Fedora: sudo dnf install libpurple-devel"
    echo "Arch: sudo pacman -S libpurple"
    exit 1
fi

if ! pkg-config --exists libwebp; then
    echo "警告: libwebp 未安装，将禁用 webp 贴纸解码"
    WEBP_FLAG="-DNoWebp=TRUE"
else
    WEBP_FLAG=""
fi

# 检查 TDLib
if [ -z "${Td_DIR}" ] && [ ! -d "/usr/local/lib/cmake/Td" ] && [ ! -d "/usr/lib/cmake/Td" ]; then
    echo "错误: TDLib 未找到"
    echo "请设置 Td_DIR 环境变量或安装 TDLib 到系统路径"
    echo "或者运行: ./build-scripts/install-tdlib.sh"
    exit 1
fi

# 创建构建目录
BUILD_DIR="build-linux"
if [ -d "$BUILD_DIR" ]; then
    echo "清理旧的构建目录..."
    rm -rf "$BUILD_DIR"
fi

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# 配置 CMake
echo "配置 CMake..."
CMAKE_ARGS=(
    -DCMAKE_BUILD_TYPE=Release
    $WEBP_FLAG
)

if [ -n "${Td_DIR}" ]; then
    CMAKE_ARGS+=(-DTd_DIR="${Td_DIR}")
fi

if [ -n "${API_ID}" ] && [ -n "${API_HASH}" ]; then
    CMAKE_ARGS+=(-DAPI_ID="${API_ID}" -DAPI_HASH="${API_HASH}")
    echo "使用自定义 API ID: ${API_ID}"
else
    echo "使用默认测试 API ID (可能有速率限制)"
fi

cmake "${CMAKE_ARGS[@]}" ..

# 编译
echo "开始编译..."
make -j$(nproc)

echo "Linux 编译完成！"
echo "生成的文件："
echo "  - $(pwd)/libtelegram-tdlib.so"
echo ""
echo "安装命令："
echo "  sudo make install"
echo ""
echo "或手动复制到插件目录："
PLUGIN_DIR=$(pkg-config purple --variable=plugindir)
echo "  sudo cp libtelegram-tdlib.so ${PLUGIN_DIR}/"
