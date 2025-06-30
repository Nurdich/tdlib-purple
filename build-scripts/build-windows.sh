#!/bin/bash
set -e

echo "开始交叉编译 tdlib-purple for Windows..."

# 检查交叉编译工具链
if ! command -v i686-w64-mingw32-gcc &> /dev/null; then
    echo "错误: MinGW-w64 交叉编译工具链未安装"
    echo "Ubuntu/Debian: sudo apt install gcc-mingw-w64-i686 g++-mingw-w64-i686"
    echo "Fedora: sudo dnf install mingw32-gcc mingw32-gcc-c++"
    echo "Arch: sudo pacman -S mingw-w64-gcc"
    exit 1
fi

# 设置默认路径
DEPS_DIR="${DEPS_DIR:-../deps}"
WIN32_DEV_DIR="${DEPS_DIR}/win32-dev"

# 检查依赖
echo "检查 Windows 编译依赖..."

# TDLib
if [ -z "${TD_WIN_DIR}" ]; then
    TD_WIN_DIR="${WIN32_DEV_DIR}/td/install/usr/local/lib/cmake/Td"
fi

if [ ! -d "${TD_WIN_DIR}" ]; then
    echo "错误: Windows TDLib 未找到: ${TD_WIN_DIR}"
    echo "请先编译 Windows 版本的 TDLib，或设置 TD_WIN_DIR 环境变量"
    exit 1
fi

# libpurple
PIDGIN_DIR="${DEPS_DIR}/pidgin-2.13.0"
if [ ! -d "${PIDGIN_DIR}" ]; then
    echo "错误: Pidgin 源码未找到: ${PIDGIN_DIR}"
    echo "请下载并解压 Pidgin 2.13.0 源码到 ${PIDGIN_DIR}"
    exit 1
fi

# GTK 开发包
GTK_DIR="${WIN32_DEV_DIR}/gtk_2_0-2.14"
if [ ! -d "${GTK_DIR}" ]; then
    echo "错误: GTK 开发包未找到: ${GTK_DIR}"
    echo "请下载 Windows GTK 开发包到 ${GTK_DIR}"
    exit 1
fi

# 创建构建目录
BUILD_DIR="build-windows"
if [ -d "$BUILD_DIR" ]; then
    echo "清理旧的构建目录..."
    rm -rf "$BUILD_DIR"
fi

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# 配置 CMake
echo "配置 Windows 交叉编译..."

# 设置可选依赖
OPTIONAL_DEPS=""

# libpng
LIBPNG_DIR="${WIN32_DEV_DIR}/libpng-1.6.37/install/usr/local"
if [ -d "${LIBPNG_DIR}" ]; then
    OPTIONAL_DEPS="$OPTIONAL_DEPS -Dlibpng_INCLUDE_DIRS=${LIBPNG_DIR}/include"
    OPTIONAL_DEPS="$OPTIONAL_DEPS -Dlibpng_LIBRARIES=${LIBPNG_DIR}/lib/libpng16.a"
fi

# libwebp
LIBWEBP_DIR="${WIN32_DEV_DIR}/libwebp-1.1.0/install/usr/local"
if [ -d "${LIBWEBP_DIR}" ]; then
    OPTIONAL_DEPS="$OPTIONAL_DEPS -Dlibwebp_INCLUDE_DIRS=${LIBWEBP_DIR}/include"
    OPTIONAL_DEPS="$OPTIONAL_DEPS -Dlibwebp_LIBRARIES=${LIBWEBP_DIR}/lib/libwebp.a"
else
    OPTIONAL_DEPS="$OPTIONAL_DEPS -DNoWebp=TRUE"
fi

# tgvoip (语音通话支持)
TGVOIP_DIR="${WIN32_DEV_DIR}/libtgvoip/install/usr/local"
if [ -d "${TGVOIP_DIR}" ]; then
    OPUS_DIR="${WIN32_DEV_DIR}/opus-1.3.1/install/usr/local"
    WEBRTC_DIR="${WIN32_DEV_DIR}/webrtc-audio-processing/install/usr/local"
    
    OPTIONAL_DEPS="$OPTIONAL_DEPS -Dtgvoip_INCLUDE_DIRS=${TGVOIP_DIR}/include/tgvoip"
    OPTIONAL_DEPS="$OPTIONAL_DEPS -Dtgvoip_LIBRARIES=${TGVOIP_DIR}/lib/libtgvoip.a"
    
    if [ -d "${OPUS_DIR}" ]; then
        OPTIONAL_DEPS="$OPTIONAL_DEPS;${OPUS_DIR}/lib/libopus.a"
    fi
    if [ -d "${WEBRTC_DIR}" ]; then
        OPTIONAL_DEPS="$OPTIONAL_DEPS;${WEBRTC_DIR}/lib/libwebrtc_audio_processing.a"
    fi
    OPTIONAL_DEPS="$OPTIONAL_DEPS;iphlpapi;winmm"
else
    OPTIONAL_DEPS="$OPTIONAL_DEPS -DNoVoip=TRUE"
fi

# API 配置
API_CONFIG=""
if [ -n "${API_ID}" ] && [ -n "${API_HASH}" ]; then
    API_CONFIG="-DAPI_ID=${API_ID} -DAPI_HASH=${API_HASH}"
    echo "使用自定义 API ID: ${API_ID}"
else
    echo "使用默认测试 API ID (可能有速率限制)"
fi

cmake \
    -DCMAKE_SYSTEM_NAME=Windows \
    -DCMAKE_C_COMPILER=i686-w64-mingw32-gcc \
    -DCMAKE_CXX_COMPILER=i686-w64-mingw32-g++ \
    -DTd_DIR="${TD_WIN_DIR}" \
    -DCMAKE_SHARED_LINKER_FLAGS="-static-libgcc -static-libstdc++" \
    -DCMAKE_EXE_LINKER_FLAGS="-static-libgcc -static-libstdc++" \
    -DNoPkgConfig=True \
    -DPurple_INCLUDE_DIRS="${PIDGIN_DIR}/libpurple;${GTK_DIR}/include/glib-2.0;${GTK_DIR}/lib/glib-2.0/include" \
    -DPurple_LIBRARIES="${PIDGIN_DIR}/libpurple/libpurple.dll.a;${GTK_DIR}/lib/libglib-2.0.dll.a;${GTK_DIR}/lib/libgthread-2.0.dll.a" \
    -DPURPLE_PLUGIN_DIR=/ \
    -DIntl_INCLUDE_DIR="${GTK_DIR}/include" \
    -DIntl_LIBRARY="${GTK_DIR}/lib/libintl.dll.a" \
    -DGLIB_LIBRARIES="${GTK_DIR}/lib/libglib-2.0.dll.a;${GTK_DIR}/lib/libgthread-2.0.dll.a" \
    -DSTANDARD_LIBRARIES_EXTRA="-Wl,-Bstatic -lpthread -Wl,-Bdynamic" \
    -DCMAKE_BUILD_TYPE=Release \
    $OPTIONAL_DEPS \
    $API_CONFIG \
    ..

# 编译
echo "开始编译..."
make -j$(nproc)

# 剥离调试信息
echo "剥离调试信息..."
i686-w64-mingw32-strip libtelegram-tdlib.dll

echo "Windows 编译完成！"
echo "生成的文件："
echo "  - $(pwd)/libtelegram-tdlib.dll"
echo ""
echo "运行时依赖检查："
strings libtelegram-tdlib.dll | grep '\.dll' | sort | uniq
