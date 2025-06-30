#!/bin/bash
set -e

echo "安装 TDLib..."

# 默认配置
TDLIB_VERSION="1.8.0"  # 使用最新的稳定版本
INSTALL_PREFIX="/usr/local"
BUILD_TYPE="Release"

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --version)
            TDLIB_VERSION="$2"
            shift 2
            ;;
        --prefix)
            INSTALL_PREFIX="$2"
            shift 2
            ;;
        --debug)
            BUILD_TYPE="Debug"
            shift
            ;;
        -h|--help)
            echo "用法: $0 [选项]"
            echo "选项:"
            echo "  --version VERSION    TDLib 版本 (默认: 1.7.9)"
            echo "  --prefix PREFIX      安装前缀 (默认: /usr/local)"
            echo "  --debug              编译调试版本"
            echo "  -h, --help           显示帮助"
            exit 0
            ;;
        *)
            echo "未知选项: $1"
            exit 1
            ;;
    esac
done

# 检查依赖
echo "检查编译依赖..."
if ! command -v cmake &> /dev/null; then
    echo "错误: cmake 未安装"
    exit 1
fi

if ! command -v git &> /dev/null; then
    echo "错误: git 未安装"
    exit 1
fi

# 检查必要的开发包
MISSING_DEPS=""

if ! command -v pkg-config &> /dev/null; then
    MISSING_DEPS="$MISSING_DEPS pkg-config"
fi

if ! pkg-config --exists zlib; then
    MISSING_DEPS="$MISSING_DEPS zlib1g-dev"
fi

if ! ldconfig -p | grep -q libssl; then
    MISSING_DEPS="$MISSING_DEPS libssl-dev"
fi

if [ -n "$MISSING_DEPS" ]; then
    echo "错误: 缺少依赖包: $MISSING_DEPS"
    echo "Ubuntu/Debian: sudo apt install $MISSING_DEPS"
    exit 1
fi

# 下载 TDLib
TDLIB_DIR="tdlib-${TDLIB_VERSION}"
if [ -d "$TDLIB_DIR" ]; then
    echo "TDLib 目录已存在，删除旧版本..."
    rm -rf "$TDLIB_DIR"
fi

echo "下载 TDLib ${TDLIB_VERSION}..."

# 特殊处理 1.7.9 版本（不存在的版本）
if [ "$TDLIB_VERSION" = "1.7.9" ]; then
    echo "警告: TDLib 1.7.9 版本不存在，尝试使用最接近的版本..."
    
    # 尝试使用 master 分支的特定提交（可能包含 1.7.9 的修复）
    echo "尝试下载 master 分支..."
    if ! git clone --depth 1 https://github.com/tdlib/td.git "$TDLIB_DIR"; then
        echo "尝试使用 1.8.0 版本..."
        TDLIB_VERSION="1.8.0"
        if ! git clone --depth 1 --branch v${TDLIB_VERSION} https://github.com/tdlib/td.git "$TDLIB_DIR"; then
            echo "错误: 下载 TDLib 失败"
            exit 1
        fi
    fi
else
    if ! git clone --depth 1 --branch v${TDLIB_VERSION} https://github.com/tdlib/td.git "$TDLIB_DIR"; then
        echo "错误: 下载 TDLib 失败"
        exit 1
    fi
fi

cd "$TDLIB_DIR"

# 检查 OpenSSL 版本
echo "检查 OpenSSL 版本..."
OPENSSL_VERSION=$(openssl version | cut -d' ' -f2)
if [[ "$OPENSSL_VERSION" < "3.0" ]]; then
    echo "警告: 检测到 OpenSSL $OPENSSL_VERSION"
    echo "建议使用 OpenSSL 3.0+ 以获得更好的 GPL 兼容性"
fi

# 创建构建目录
BUILD_DIR="build"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# 配置 CMake
echo "配置 CMake..."
cmake \
    -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
    -DTD_ENABLE_LTO=ON \
    ..

# 编译
echo "编译 TDLib (这可能需要一些时间)..."
make -j$(nproc)

# 安装
if [ "$INSTALL_PREFIX" = "/usr/local" ] || [ "$INSTALL_PREFIX" = "/usr" ]; then
    echo "安装到系统目录需要管理员权限..."
    sudo make install
    
    # 更新链接器缓存
    sudo ldconfig
else
    echo "安装到用户目录: $INSTALL_PREFIX"
    make install
    
    echo "添加到环境变量:"
    echo "export PKG_CONFIG_PATH=$INSTALL_PREFIX/lib/pkgconfig:\$PKG_CONFIG_PATH"
    echo "export LD_LIBRARY_PATH=$INSTALL_PREFIX/lib:\$LD_LIBRARY_PATH"
fi

echo "TDLib 安装完成！"
echo "版本: $TDLIB_VERSION"
echo "安装路径: $INSTALL_PREFIX"
echo ""
echo "cmake 查找路径: $INSTALL_PREFIX/lib/cmake/Td"
