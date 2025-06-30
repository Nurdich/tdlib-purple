# Windows Build Instructions

This document describes how to build the telegram-tdlib plugin for Windows using cross-compilation on Linux.

## Prerequisites

### System Requirements
- Linux system (Ubuntu 20.04+ recommended)
- At least 4GB of free disk space
- Internet connection for downloading dependencies

### Required Packages
- MinGW-w64 cross-compiler
- CMake 3.16+
- Git
- wget, unzip, zip
- gettext

## Quick Start

The easiest way to build for Windows is to use the provided build script:

```bash
chmod +x build-windows.sh
./build-windows.sh
```

This script will:
1. Install required dependencies
2. Download and build OpenSSL for Windows
3. Download and build TDLib for Windows
4. Download Windows versions of GTK/GLib and libpurple
5. Build the telegram-tdlib plugin
6. Create a release package with all necessary DLL files

## Manual Build Process

If you prefer to build manually or need to customize the build process:

### 1. Install Dependencies

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install -y \
    mingw-w64 \
    mingw-w64-tools \
    cmake \
    make \
    wget \
    unzip \
    libz-mingw-w64-dev \
    gettext \
    zip
```

**Fedora:**
```bash
sudo dnf install -y \
    mingw64-gcc \
    mingw64-gcc-c++ \
    cmake \
    make \
    wget \
    unzip \
    zip
```

### 2. Build OpenSSL

```bash
mkdir -p deps && cd deps
wget https://www.openssl.org/source/openssl-3.0.15.tar.gz
tar -xzf openssl-3.0.15.tar.gz
cd openssl-3.0.15

./Configure mingw --cross-compile-prefix=i686-w64-mingw32- \
    --prefix="$(pwd)/install" \
    no-shared \
    no-tests

make -j$(nproc)
make install_sw
cd ..
```

### 3. Build TDLib

```bash
git clone https://github.com/tdlib/td.git
cd td
git submodule update --init --recursive
mkdir build && cd build

cmake -DCMAKE_SYSTEM_NAME=Windows \
      -DCMAKE_C_COMPILER=i686-w64-mingw32-gcc \
      -DCMAKE_CXX_COMPILER=i686-w64-mingw32-g++ \
      -DOPENSSL_FOUND=True \
      -DOPENSSL_SSL_LIBRARY="../openssl-3.0.15/install/lib/libssl.a;ws2_32" \
      -DOPENSSL_CRYPTO_LIBRARY="../openssl-3.0.15/install/lib/libcrypto.a;ws2_32" \
      -DOPENSSL_INCLUDE_DIR="../openssl-3.0.15/install/include" \
      -DZLIB_FOUND=1 \
      -DZLIB_LIBRARIES=/usr/i686-w64-mingw32/lib/libz.a \
      -DZLIB_INCLUDE_DIRS=/usr/i686-w64-mingw32/include \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_FLAGS="-pthread" \
      -DCMAKE_C_FLAGS="-pthread" \
      ..

make -j$(nproc)
make install DESTDIR="../win32-dev/td"
cd ../..
```

### 4. Download Windows Dependencies

```bash
# Download GTK development libraries
mkdir -p win32-dev
wget https://ftp.gnome.org/pub/gnome/binaries/win32/gtk+/2.24/gtk+-bundle_2.24.10-20120208_win32.zip
unzip gtk+-bundle_2.24.10-20120208_win32.zip -d win32-dev/gtk_2_0-2.14

# Download Pidgin Windows binaries
wget https://sourceforge.net/projects/pidgin/files/Pidgin/2.13.0/pidgin-2.13.0-win32-bin.zip
unzip pidgin-2.13.0-win32-bin.zip
```

### 5. Create libpurple Import Library

```bash
cd pidgin-2.13.0-win32bin

# Create export definition file (see build-windows.sh for complete list)
cat > libpurple_exports.def << 'EOF'
EXPORTS
purple_account_get_bool
purple_account_get_connection
# ... (add all required exports)
EOF

# Generate import library
i686-w64-mingw32-dlltool -D libpurple.dll -d libpurple_exports.def -l libpurple.dll.a
cd ..
```

### 6. Build the Plugin

```bash
mkdir build-windows && cd build-windows

cmake -DCMAKE_SYSTEM_NAME=Windows \
      -DCMAKE_C_COMPILER=i686-w64-mingw32-gcc \
      -DCMAKE_CXX_COMPILER=i686-w64-mingw32-g++ \
      -DTd_DIR="../deps/win32-dev/td/usr/local/lib/cmake/Td" \
      -DCMAKE_SHARED_LINKER_FLAGS="-static-libgcc -static-libstdc++ -L../deps/win32-dev/gtk_2_0-2.14/lib -L../deps/pidgin-2.13.0-win32bin" \
      -DCMAKE_EXE_LINKER_FLAGS="-static-libgcc -static-libstdc++ -L../deps/win32-dev/gtk_2_0-2.14/lib -L../deps/pidgin-2.13.0-win32bin" \
      -DNoPkgConfig=True \
      -DNoWebp=True \
      -DNoVoip=True \
      -DNoTranslations=True \
      -DPurple_INCLUDE_DIRS="../deps/pidgin-2.13.0/libpurple;../deps/win32-dev/gtk_2_0-2.14/include/glib-2.0;../deps/win32-dev/gtk_2_0-2.14/lib/glib-2.0/include" \
      -DPurple_LIBRARIES="../deps/pidgin-2.13.0-win32bin/libpurple.dll.a;../deps/win32-dev/gtk_2_0-2.14/lib/libglib-2.0.dll.a;../deps/win32-dev/gtk_2_0-2.14/lib/libgthread-2.0.dll.a" \
      -DCMAKE_BUILD_TYPE=Release \
      ..

make -j$(nproc)
```

### 7. Create Release Package

```bash
mkdir release-windows

# Copy main plugin
cp build-windows/libtelegram-tdlib.dll release-windows/

# Copy dependencies
cp deps/pidgin-2.13.0-win32bin/libpurple.dll release-windows/
cp deps/win32-dev/gtk_2_0-2.14/bin/libglib-2.0-0.dll release-windows/
cp deps/win32-dev/gtk_2_0-2.14/bin/libgthread-2.0-0.dll release-windows/
cp deps/win32-dev/td/usr/local/bin/libtdjson.dll release-windows/

# Create zip package
zip -r telegram-pidgin-plugin-windows.zip release-windows/
```

## Build Configuration Options

The build can be customized with the following CMake options:

- `-DNoWebp=True` - Disable WebP image support (reduces dependencies)
- `-DNoVoip=True` - Disable voice call support (reduces dependencies)
- `-DNoTranslations=True` - Disable internationalization (reduces dependencies)
- `-DCMAKE_BUILD_TYPE=Release` - Build optimized release version
- `-DCMAKE_BUILD_TYPE=Debug` - Build debug version with symbols

## Troubleshooting

### Common Issues

1. **MinGW not found**: Make sure MinGW-w64 is properly installed and in PATH
2. **OpenSSL build fails**: Ensure you have the correct MinGW prefix
3. **TDLib build fails**: Check that all submodules are properly initialized
4. **Plugin linking fails**: Verify that all import libraries are correctly generated

### Build Logs

The build script provides colored output to help identify issues:
- Green: Informational messages
- Yellow: Warnings
- Red: Errors

### Debugging

To debug build issues:
1. Run the build script with verbose output: `bash -x build-windows.sh`
2. Check individual component builds in the `deps/` directory
3. Verify CMake configuration output for missing dependencies

## Output Files

After a successful build, you'll have:

- `libtelegram-tdlib.dll` - Main plugin (≈63MB)
- `libtdjson.dll` - TDLib library (≈62MB)
- `libpurple.dll` - Purple protocol library (≈856KB)
- `libglib-2.0-0.dll` - GLib library (≈1.2MB)
- `libgthread-2.0-0.dll` - GLib threading (≈44KB)
- `telegram-pidgin-plugin-windows.zip` - Complete package (≈32MB)

## Installation on Windows

1. Install Pidgin from https://pidgin.im/
2. Extract the zip file
3. Copy all DLL files to Pidgin's plugins directory
4. Restart Pidgin
5. Add a new Telegram account with your phone number

## Notes

- This builds a 32-bit version compatible with most Windows systems
- The plugin uses static linking for C++ runtime to reduce dependencies
- All necessary libraries are included in the release package
- The build process downloads approximately 200MB of dependencies
