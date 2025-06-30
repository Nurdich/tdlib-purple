#!/bin/bash
set -e

echo "开始交叉编译 TDLib for Windows..."

# 检查交叉编译工具链
if ! command -v i686-w64-mingw32-gcc &> /dev/null; then
    echo "错误: MinGW-w64 交叉编译工具链未安装" >&2
    echo "Ubuntu/Debian: sudo apt install gcc-mingw-w64-i686 g++-mingw-w64-i686" >&2
    exit 1
fi



# 设置目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
DEPS_DIR="${ROOT_DIR}/deps"
WIN32_DEV_DIR="${DEPS_DIR}/win32-dev"
TDLIB_SRC_DIR="${ROOT_DIR}/tdlib-1.8.0"
TDLIB_BUILD_DIR="${TDLIB_SRC_DIR}/build-windows"
INSTALL_DIR="${WIN32_DEV_DIR}/td"

mkdir -p "$DEPS_DIR" "$WIN32_DEV_DIR" "$TDLIB_BUILD_DIR"

# 编译 OpenSSL (如果需要)
OPENSSL_INSTALL_DIR="${WIN32_DEV_DIR}/openssl"
if [ ! -f "${OPENSSL_INSTALL_DIR}/lib/libssl.a" ]; then
    echo "OpenSSL for Windows 未找到，开始编译..."
    cd "$DEPS_DIR"
    if [ ! -d "openssl-3.0.13" ]; then
        wget https://www.openssl.org/source/openssl-3.0.13.tar.gz
        tar -xzf openssl-3.0.13.tar.gz
    fi
    cd openssl-3.0.13
    ./Configure --cross-compile-prefix=i686-w64-mingw32- mingw no-shared --prefix="$OPENSSL_INSTALL_DIR"
    make -j$(nproc)
    make install_sw
    echo "OpenSSL for Windows 编译完成"
else
    echo "找到已编译的 OpenSSL for Windows"
fi

# 编译 TDLib
echo "开始配置和编译 TDLib for Windows..."
cd "$TDLIB_BUILD_DIR"

cmake -DCMAKE_SYSTEM_NAME=Windows \
    -DCMAKE_C_COMPILER=i686-w64-mingw32-gcc \
    -DCMAKE_CXX_COMPILER=i686-w64-mingw32-g++ \
    -DOPENSSL_FOUND=True \
    -DOPENSSL_SSL_LIBRARY="${OPENSSL_INSTALL_DIR}/lib/libssl.a;ws2_32" \
    -DOPENSSL_CRYPTO_LIBRARY="${OPENSSL_INSTALL_DIR}/lib/libcrypto.a;crypt32;ws2_32" \
    -DOPENSSL_INCLUDE_DIR="${OPENSSL_INSTALL_DIR}/include" \
    -DZLIB_FOUND=1 \
    -DZLIB_LIBRARIES="$ZLIB_PATH" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}/usr/local" \
    -DTD_ENABLE_LTO=ON \
    "$TDLIB_SRC_DIR"

make -j$(nproc)
make install

echo ""
echo "TDLib for Windows 编译和安装完成！"
echo "安装路径: ${INSTALL_DIR}"
