#!/bin/bash
set -e

echo "一键编译 tdlib-purple (Linux + Windows)"

# 默认配置
SKIP_TDLIB=false
SKIP_LINUX=false
SKIP_WINDOWS=false

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-tdlib)
            SKIP_TDLIB=true
            shift
            ;;
        --skip-linux)
            SKIP_LINUX=true
            shift
            ;;
        --skip-windows)
            SKIP_WINDOWS=true
            shift
            ;;
        --api-id)
            export API_ID="$2"
            shift 2
            ;;
        --api-hash)
            export API_HASH="$2"
            shift 2
            ;;
        -h|--help)
            echo "用法: $0 [选项]"
            echo "选项:"
            echo "  --skip-tdlib         跳过 TDLib 安装"
            echo "  --skip-linux         跳过 Linux 编译"
            echo "  --skip-windows       跳过 Windows 编译"
            echo "  --api-id ID          自定义 API ID"
            echo "  --api-hash HASH      自定义 API Hash"
            echo "  -h, --help           显示帮助"
            exit 0
            ;;
        *)
            echo "未知选项: $1"
            exit 1
            ;;
    esac
done

# 脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$(dirname "$SCRIPT_DIR")"

echo "当前目录: $(pwd)"
echo "============================================"

# 1. 安装 TDLib
if [ "$SKIP_TDLIB" = false ]; then
    echo "步骤 1: 安装 TDLib"
    echo "============================================"
    if [ -d "/usr/local/lib/cmake/Td" ] || [ -d "/usr/lib/cmake/Td" ]; then
        echo "TDLib 已安装，跳过..."
    else
        "$SCRIPT_DIR/install-tdlib.sh"
    fi
    echo ""
fi

# 2. 编译 Linux 版本
if [ "$SKIP_LINUX" = false ]; then
    echo "步骤 2: 编译 Linux 版本"
    echo "============================================"
    "$SCRIPT_DIR/build-linux.sh"
    echo ""
fi

# 3. 编译 Windows 版本
if [ "$SKIP_WINDOWS" = false ]; then
    echo "步骤 3: 编译 Windows 版本"
    echo "============================================"
    if command -v i686-w64-mingw32-gcc &> /dev/null; then
        "$SCRIPT_DIR/build-windows.sh"
    else
        echo "警告: MinGW-w64 未安装，跳过 Windows 编译"
        echo "安装方法:"
        echo "  Ubuntu/Debian: sudo apt install gcc-mingw-w64-i686 g++-mingw-w64-i686"
        echo "  Fedora: sudo dnf install mingw32-gcc mingw32-gcc-c++"
        echo "  Arch: sudo pacman -S mingw-w64-gcc"
    fi
    echo ""
fi

echo "============================================"
echo "编译完成！"
echo "============================================"

# 显示结果
if [ -f "build-linux/libtelegram-tdlib.so" ]; then
    echo "✓ Linux 版本: build-linux/libtelegram-tdlib.so"
fi

if [ -f "build-windows/libtelegram-tdlib.dll" ]; then
    echo "✓ Windows 版本: build-windows/libtelegram-tdlib.dll"
fi

echo ""
echo "安装说明:"
echo "Linux: 复制 .so 文件到 libpurple 插件目录"
echo "Windows: 复制 .dll 文件到 Pidgin 插件目录"
