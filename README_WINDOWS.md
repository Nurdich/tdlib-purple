# 🚀 Telegram Plugin for Pidgin - Windows Edition

This repository contains Windows builds and cross-compilation tools for the telegram-tdlib plugin for Pidgin.

## 📥 Quick Download & Install

### Option 1: Pre-compiled Windows Build (Recommended)

**Download the ready-to-use Windows plugin:**

1. **Get the files**: Download all `windows-build-part-*` files from this repository
2. **Reassemble**: Run `bash reassemble-windows-build.sh` (or use Git Bash on Windows)
3. **Extract**: Unzip `telegram-pidgin-plugin-windows.zip`
4. **Install**: Copy all DLL files to your Pidgin plugins directory:
   - `C:\Program Files (x86)\Pidgin\plugins\`
   - Or: `%APPDATA%\.purple\plugins\`
5. **Restart** Pidgin
6. **Add Account**: Accounts → Manage Accounts → Add → Telegram
7. **Login**: Enter your phone number with country code (e.g., +1234567890)

### Option 2: Build from Source

**Build your own Windows version:**

```bash
chmod +x build-windows.sh
./build-windows.sh
```

## 📦 What's Included

### Pre-compiled Package Contents
- `libtelegram-tdlib.dll` - Main Telegram plugin (~63MB)
- `libtdjson.dll` - TDLib library (~62MB)
- `libpurple.dll` - Purple protocol library (~856KB)
- `libglib-2.0-0.dll` - GLib library (~1.2MB)
- `libgthread-2.0-0.dll` - GLib threading library (~44KB)
- `README.md` - Installation and usage instructions

### Build Tools
- `build-windows.sh` - Automated cross-compilation script
- `WINDOWS_BUILD.md` - Detailed build documentation
- `reassemble-windows-build.sh` - File reconstruction script

## ✨ Features

- ✅ **Send/receive messages** - Full text messaging support
- ✅ **Group chats** - Join and participate in Telegram groups
- ✅ **File transfers** - Send/receive photos, documents, and files
- ✅ **Contact management** - Add, remove, and manage contacts
- ✅ **Status updates** - Online/offline/away status
- ✅ **Message history** - Previous conversations load automatically
- ✅ **Stickers** - Basic sticker support
- ✅ **Channels** - Read-only channel support

## 🔧 System Requirements

- **Operating System**: Windows 7/8/10/11 (32-bit or 64-bit)
- **Pidgin Version**: 2.13.0 or later
- **Disk Space**: ~150MB free space
- **Network**: Internet connection required

## 🛠️ Build Information

- **Cross-compiled** using MinGW-w64 on Linux
- **TDLib version**: Latest official Telegram library
- **Compiler**: GCC 10.0.0
- **Architecture**: 32-bit Windows (compatible with both 32/64-bit Windows)
- **Build date**: June 30, 2025

## 🐛 Troubleshooting

### Plugin doesn't appear in protocol list
- Ensure ALL DLL files are in the plugins directory
- Restart Pidgin completely (close all windows)
- Check Pidgin version (must be 2.13.0 or later)
- Try copying DLLs to main Pidgin directory if plugins folder doesn't work

### Cannot connect to Telegram
- Verify phone number format includes country code (+1234567890)
- Check firewall settings (allow Pidgin network access)
- Ensure stable internet connection
- Try logging out and back in

### Missing DLL errors
- Extract ALL files from the zip package
- Install Visual C++ Redistributable if needed
- Try running Pidgin as administrator
- Check Windows Event Viewer for detailed error messages

### File transfer issues
- Check available disk space
- Verify download folder permissions
- Large files may take time to process

## 📚 Documentation

- **[WINDOWS_BUILD.md](WINDOWS_BUILD.md)** - Complete build instructions
- **[DOWNLOAD_WINDOWS_BUILD.md](DOWNLOAD_WINDOWS_BUILD.md)** - Quick download guide
- **Original project**: https://github.com/BenWiederhake/tdlib-purple

## 🤝 Contributing

This is a community contribution to make Windows builds more accessible. 

### Build Improvements
- The automated build script handles all dependencies
- Cross-compilation eliminates need for Windows development environment
- Complete documentation for reproducible builds

### Testing
- Tested on Windows 7, 10, and 11
- Compatible with both 32-bit and 64-bit Windows
- Verified with Pidgin 2.13.0 and 2.14.x

## 📄 License

This plugin is distributed under the same license as the original tdlib-purple project.

## 🆘 Support

- **Issues**: Report problems in the GitHub issues
- **Original project**: https://github.com/BenWiederhake/tdlib-purple
- **Build discussion**: https://github.com/BenWiederhake/tdlib-purple/issues/19

## 🎉 Ready to Chat!

Once installed, you can use Telegram through Pidgin just like any other protocol. Enjoy secure messaging with the familiar Pidgin interface!

---

**Note**: This is an unofficial Windows build. The official project is maintained by BenWiederhake.
