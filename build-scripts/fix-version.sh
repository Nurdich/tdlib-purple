#!/bin/bash
set -e

echo "修补 tdlib-purple 以支持不同 TDLib 版本..."

# 当前目录应该是项目根目录
if [ ! -f "CMakeLists.txt" ]; then
    echo "错误: 请在项目根目录运行此脚本"
    exit 1
fi

modify_version_requirement() {
    local new_version="$1"
    echo "修改版本要求为: $new_version"
    
    if [ "$new_version" = "master" ]; then
        # 对于 master 分支，跳过版本检查
        echo "跳过版本检查 (master 分支)"
        sed -i 's/if (NOT(${TDLIB_VERSION_NUMBER} EQUAL [0-9]*))/#if (NOT(${TDLIB_VERSION_NUMBER} EQUAL 10800))/' CMakeLists.txt
        sed -i 's/endif (NOT(${TDLIB_VERSION_NUMBER} EQUAL [0-9]*))/#endif (NOT(${TDLIB_VERSION_NUMBER} EQUAL 10800))/' CMakeLists.txt
    else
        # 计算新的版本号
        local major=$(echo "$new_version" | cut -d. -f1)
        local minor=$(echo "$new_version" | cut -d. -f2)
        local patch=$(echo "$new_version" | cut -d. -f3)
        local version_number=$((10000 * major + 100 * minor + patch))
        
        echo "新版本号: $version_number"
        
        # 更新 CMakeLists.txt
        sed -i "s/10709/$version_number/g" CMakeLists.txt
        sed -i "s/tdlib version 1\.7\.9/tdlib version $new_version/g" CMakeLists.txt
    fi
    
    echo "版本要求已更新"
}

# 检查当前要求的版本
REQUIRED_VERSION=$(grep -o "tdlib version [0-9.]*" CMakeLists.txt | cut -d' ' -f3)
echo "项目要求的 TDLib 版本: $REQUIRED_VERSION"

# 检查实际可用的版本
echo "检查可用的 TDLib 版本..."
AVAILABLE_VERSIONS=$(curl -s https://api.github.com/repos/tdlib/td/tags | jq -r '.[].name' | grep -E '^v1\.' | sed 's/^v//' | head -5)
echo "可用版本:"
echo "$AVAILABLE_VERSIONS"

# 如果要求的版本不存在，询问用户选择或自动使用最新版本
if ! echo "$AVAILABLE_VERSIONS" | grep -q "^$REQUIRED_VERSION$"; then
    echo ""
    echo "警告: 要求的版本 $REQUIRED_VERSION 不存在"
    
    # 自动使用最新版本
    LATEST_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -1)
    echo "自动使用最新版本: $LATEST_VERSION"
    modify_version_requirement "$LATEST_VERSION"
else
    echo "版本 $REQUIRED_VERSION 可用"
fi

echo "版本兼容性检查完成"
