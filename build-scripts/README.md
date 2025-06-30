# tdlib-purple 编译指南

这个项目是 Telegram 的 libpurple 插件，支持在 Pidgin、Finch 和其他支持 libpurple 的客户端中使用 Telegram。

## 快速开始

### 一键编译 (推荐)

```bash
# 给脚本执行权限
chmod +x build-scripts/*.sh

# 一键编译 Linux 和 Windows 版本
./build-scripts/build-all.sh

# 使用自定义 API (可选，避免速率限制)
./build-scripts/build-all.sh --api-id YOUR_API_ID --api-hash YOUR_API_HASH
```

### 分步编译

```bash
# 1. 安装 TDLib
./build-scripts/install-tdlib.sh

# 2. 编译 Linux 版本
./build-scripts/build-linux.sh

# 3. 编译 Windows 版本 (需要 MinGW-w64)
./build-scripts/build-windows.sh
```

## 系统要求

### Linux 编译环境

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install \
    build-essential cmake git pkg-config \
    libpurple-dev libssl-dev zlib1g-dev \
    libwebp-dev libpng-dev \
    gettext
```

**Fedora:**
```bash
sudo dnf install \
    gcc gcc-c++ cmake git pkg-config \
    libpurple-devel openssl-devel zlib-devel \
    libwebp-devel libpng-devel \
    gettext-devel
```

**Arch Linux:**
```bash
sudo pacman -S \
    base-devel cmake git pkg-config \
    libpurple openssl zlib \
    libwebp libpng \
    gettext
```

### Windows 交叉编译 (可选)

**Ubuntu/Debian:**
```bash
sudo apt install gcc-mingw-w64-i686 g++-mingw-w64-i686
```

**Fedora:**
```bash
sudo dnf install mingw32-gcc mingw32-gcc-c++
```

**Arch Linux:**
```bash
sudo pacman -S mingw-w64-gcc
```

## 依赖说明

### 必需依赖

- **TDLib 1.7.9**: Telegram Database Library
- **libpurple**: Purple 协议库
- **OpenSSL**: 加密库
- **zlib**: 压缩库
- **CMake 3.2+**: 构建系统

### 可选依赖

- **libwebp**: WebP 贴纸支持
- **libpng**: PNG 图像支持
- **rlottie**: 动画贴纸支持 (已包含)
- **libtgvoip**: 语音通话支持
- **gettext**: 国际化支持

## API 配置

### 获取 API 凭据

1. 访问 https://my.telegram.org/
2. 登录你的 Telegram 账号
3. 转到 "API development tools"
4. 创建应用并获取 `api_id` 和 `api_hash`

### 使用自定义 API

```bash
# 方法 1: 环境变量
export API_ID=YOUR_API_ID
export API_HASH=YOUR_API_HASH
./build-scripts/build-all.sh

# 方法 2: 命令行参数
./build-scripts/build-all.sh --api-id YOUR_API_ID --api-hash YOUR_API_HASH

# 方法 3: CMake 参数
cmake -DAPI_ID=YOUR_API_ID -DAPI_HASH=YOUR_API_HASH ..
```

## 安装

### Linux

```bash
# 自动安装 (推荐)
cd build-linux
sudo make install

# 手动安装
PLUGIN_DIR=$(pkg-config purple --variable=plugindir)
sudo cp build-linux/libtelegram-tdlib.so $PLUGIN_DIR/
```

### Windows

1. 下载并安装 Pidgin
2. 复制 `build-windows/libtelegram-tdlib.dll` 到 Pidgin 插件目录
   - 通常位于: `C:\Program Files\Pidgin\plugins\`
   - 或用户目录: `%APPDATA%\.purple\plugins\`

## 编译选项

### CMake 选项

```bash
# 禁用功能
-DNoWebp=TRUE           # 禁用 WebP 贴纸
-DNoLottie=TRUE         # 禁用动画贴纸
-DNoTranslations=TRUE   # 禁用翻译
-DNoVoip=TRUE          # 禁用语音通话

# 自定义路径
-DTd_DIR=/path/to/tdlib/cmake
-DCMAKE_INSTALL_PREFIX=/custom/path

# API 配置
-DAPI_ID=YOUR_API_ID
-DAPI_HASH=YOUR_API_HASH
```

### 环境变量

```bash
# TDLib 路径
export Td_DIR=/path/to/tdlib/cmake

# Windows 交叉编译依赖
export DEPS_DIR=/path/to/windows/deps
export TD_WIN_DIR=/path/to/windows/tdlib
```

## 故障排除

### TDLib 版本不匹配

```bash
# 检查要求的版本
grep -o "tdlib version.*" CMakeLists.txt

# 安装特定版本
./build-scripts/install-tdlib.sh --version 1.7.9
```

### 缺少依赖

```bash
# 检查 Purple 开发包
pkg-config --exists purple && echo "OK" || echo "Missing"

# 检查 WebP 支持
pkg-config --exists libwebp && echo "OK" || echo "Missing"
```

### Windows 编译问题

确保已安装所有 Windows 依赖:
- Pidgin 2.13.0 源码
- GTK+ 2.0 开发包
- libpng, libwebp 等库

参考 `cross-mingw32.md` 了解详细的 Windows 编译步骤。

## 使用说明

1. 启动 Pidgin
2. 添加账号 → 选择 "Telegram (tdlib)"
3. 输入手机号码 (带国家代码，如 +86)
4. 按提示完成验证

## 开发

### 运行测试

```bash
cd build-linux
make run-tests
```

### 调试模式

```bash
# 启用调试日志
pidgin -d >&~/pidgin.log

# 编译调试版本
cmake -DCMAKE_BUILD_TYPE=Debug ..
```

## 许可证

这个项目使用 GPL 许可证。为了更好的兼容性，建议使用 OpenSSL 3.0+。

## 支持

- GitHub Issues: https://github.com/ars3niy/tdlib-purple/issues
- Telegram 群组: https://t.me/joinchat/BuRiSBO0mMw7Lxy0ufVO5g
