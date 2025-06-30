# 📥 Download Windows Build

## 🎯 Quick Download

**Pre-compiled Windows build is available!**

### 📍 Download Location

**GitHub Release**: https://github.com/Nurdich/tdlib-purple/releases/tag/windows-build-v1.0

### 📦 What You Get

- `telegram-pidgin-plugin-windows.zip` (32MB)
- Contains all necessary DLL files
- Ready-to-use Windows plugin
- Installation instructions included

### ⚡ Quick Install

1. Download the zip file from the link above
2. Extract to: `C:\Program Files (x86)\Pidgin\plugins\`
3. Restart Pidgin
4. Add Telegram account with your phone number

### 🔧 Alternative: Build Yourself

If you prefer to build from source:

```bash
git clone https://github.com/BenWiederhake/tdlib-purple.git
cd tdlib-purple
chmod +x build-windows.sh
./build-windows.sh
```

### 📋 File Contents

```
telegram-pidgin-plugin-windows.zip
├── libtelegram-tdlib.dll     # Main plugin (63MB)
├── libtdjson.dll             # TDLib library (62MB)  
├── libpurple.dll             # Purple library (856KB)
├── libglib-2.0-0.dll         # GLib library (1.2MB)
├── libgthread-2.0-0.dll      # GLib threading (44KB)
└── README.md                 # Installation guide
```

### ✅ Tested & Working

- ✅ Windows 7/8/10/11 compatible
- ✅ Pidgin 2.13.0+ supported
- ✅ All core Telegram features
- ✅ Messaging, groups, file transfers
- ✅ Contact management, status updates

### 🆘 Need Help?

- Check the README.md in the zip file
- Comment on GitHub Issue #19
- Verify Pidgin installation

**Ready to use Telegram in Pidgin! 🚀**
