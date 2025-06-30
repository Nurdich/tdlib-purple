#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "============================================"
echo "    tdlib-purple 编译工具"
echo "    Telegram libpurple 插件"
echo "============================================"
echo -e "${NC}"

# 检查操作系统
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="Linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macOS"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    OS="Windows"
else
    OS="Unknown"
fi

echo -e "检测到系统: ${GREEN}$OS${NC}"
echo ""

# 检查基本工具
echo "检查编译环境..."

check_command() {
    if command -v "$1" &> /dev/null; then
        echo -e "  ✓ $1: ${GREEN}已安装${NC}"
        return 0
    else
        echo -e "  ✗ $1: ${RED}未找到${NC}"
        return 1
    fi
}

# 基本工具检查
MISSING_BASIC=0
check_command "cmake" || MISSING_BASIC=1
check_command "git" || MISSING_BASIC=1
check_command "make" || MISSING_BASIC=1

if [ "$OS" = "Linux" ]; then
    check_command "gcc" || MISSING_BASIC=1
    check_command "g++" || MISSING_BASIC=1
    check_command "pkg-config" || MISSING_BASIC=1
fi

echo ""

# 依赖检查
echo "检查编译依赖..."

check_pkg_config() {
    if pkg-config --exists "$1" 2>/dev/null; then
        VERSION=$(pkg-config --modversion "$1" 2>/dev/null)
        echo -e "  ✓ $1: ${GREEN}$VERSION${NC}"
        return 0
    else
        echo -e "  ✗ $1: ${RED}未找到${NC}"
        return 1
    fi
}

MISSING_DEPS=0
if [ "$OS" = "Linux" ]; then
    check_pkg_config "purple" || MISSING_DEPS=1
    check_pkg_config "openssl" || MISSING_DEPS=1
    check_pkg_config "zlib" || MISSING_DEPS=1
    
    # 可选依赖
    check_pkg_config "libwebp" || echo -e "  ⚠ libwebp: ${YELLOW}可选依赖未找到${NC}"
    check_pkg_config "libpng" || echo -e "  ⚠ libpng: ${YELLOW}可选依赖未找到${NC}"
fi

echo ""

# TDLib 检查
echo "检查 TDLib..."
TDLIB_FOUND=0
if [ -d "/usr/local/lib/cmake/Td" ]; then
    echo -e "  ✓ TDLib: ${GREEN}已安装 (/usr/local)${NC}"
    TDLIB_FOUND=1
elif [ -d "/usr/lib/cmake/Td" ]; then
    echo -e "  ✓ TDLib: ${GREEN}已安装 (/usr)${NC}"
    TDLIB_FOUND=1
elif [ -n "$Td_DIR" ] && [ -d "$Td_DIR" ]; then
    echo -e "  ✓ TDLib: ${GREEN}已安装 ($Td_DIR)${NC}"
    TDLIB_FOUND=1
else
    echo -e "  ✗ TDLib: ${RED}未找到${NC}"
fi

echo ""

# 交叉编译工具检查
echo "检查 Windows 交叉编译环境..."
if command -v i686-w64-mingw32-gcc &> /dev/null; then
    echo -e "  ✓ MinGW-w64: ${GREEN}已安装${NC}"
    MINGW_AVAILABLE=1
else
    echo -e "  ✗ MinGW-w64: ${RED}未安装${NC}"
    MINGW_AVAILABLE=0
fi

echo ""
echo "============================================"

# 显示建议
if [ $MISSING_BASIC -eq 1 ]; then
    echo -e "${RED}❌ 缺少基本编译工具${NC}"
    echo "请先安装基本开发工具:"
    
    if [ "$OS" = "Linux" ]; then
        if command -v apt &> /dev/null; then
            echo "  sudo apt install build-essential cmake git pkg-config"
        elif command -v dnf &> /dev/null; then
            echo "  sudo dnf install gcc gcc-c++ cmake git pkg-config"
        elif command -v pacman &> /dev/null; then
            echo "  sudo pacman -S base-devel cmake git pkg-config"
        fi
    fi
    echo ""
fi

if [ $MISSING_DEPS -eq 1 ]; then
    echo -e "${RED}❌ 缺少编译依赖${NC}"
    echo "请安装依赖包:"
    
    if command -v apt &> /dev/null; then
        echo "  sudo apt install libpurple-dev libssl-dev zlib1g-dev libwebp-dev libpng-dev gettext"
    elif command -v dnf &> /dev/null; then
        echo "  sudo dnf install libpurple-devel openssl-devel zlib-devel libwebp-devel libpng-devel gettext-devel"
    elif command -v pacman &> /dev/null; then
        echo "  sudo pacman -S libpurple openssl zlib libwebp libpng gettext"
    fi
    echo ""
fi

if [ $MINGW_AVAILABLE -eq 0 ]; then
    echo -e "${YELLOW}⚠ Windows 交叉编译不可用${NC}"
    echo "要编译 Windows 版本，请安装 MinGW-w64:"
    
    if command -v apt &> /dev/null; then
        echo "  sudo apt install gcc-mingw-w64-i686 g++-mingw-w64-i686"
    elif command -v dnf &> /dev/null; then
        echo "  sudo dnf install mingw32-gcc mingw32-gcc-c++"
    elif command -v pacman &> /dev/null; then
        echo "  sudo pacman -S mingw-w64-gcc"
    fi
    echo ""
fi

# 如果环境OK，显示编译选项
if [ $MISSING_BASIC -eq 0 ] && [ $MISSING_DEPS -eq 0 ]; then
    echo -e "${GREEN}✅ 编译环境就绪${NC}"
    echo ""
    echo "编译选项:"
    echo ""
    
    if [ $TDLIB_FOUND -eq 0 ]; then
        echo -e "${BLUE}1. 一键编译 (推荐)${NC}"
        echo "   ./build-scripts/build-all.sh"
        echo "   (将自动安装 TDLib 和编译所有版本)"
        echo ""
    fi
    
    echo -e "${BLUE}2. 分步编译${NC}"
    if [ $TDLIB_FOUND -eq 0 ]; then
        echo "   ./build-scripts/install-tdlib.sh    # 安装 TDLib"
    fi
    echo "   ./build-scripts/build-linux.sh      # 编译 Linux 版本"
    if [ $MINGW_AVAILABLE -eq 1 ]; then
        echo "   ./build-scripts/build-windows.sh    # 编译 Windows 版本"
    fi
    echo ""
    
    echo -e "${BLUE}3. 使用 Makefile${NC}"
    echo "   make build-all    # 一键编译"
    echo "   make linux        # 只编译 Linux"
    if [ $MINGW_AVAILABLE -eq 1 ]; then
        echo "   make windows      # 只编译 Windows"
    fi
    echo "   make install      # 编译并安装 Linux 版本"
    echo ""
    
    echo -e "${YELLOW}💡 提示:${NC}"
    echo "• 获取 Telegram API 凭据: https://my.telegram.org/"
    echo "• 使用自定义 API: --api-id YOUR_ID --api-hash YOUR_HASH"
    echo "• 查看详细说明: build-scripts/README.md"
fi

echo "============================================"
