# Telegram Plugin for Pidgin (Windows)

This is a Windows build of the telegram-tdlib plugin for Pidgin, which allows you to use Telegram through the Pidgin instant messaging client.

## Installation

1. **Install Pidgin**: Download and install Pidgin from https://pidgin.im/

2. **Copy plugin files**: Copy all the DLL files from this package to your Pidgin plugins directory:
   - Default location: `C:\Program Files (x86)\Pidgin\plugins\`
   - Or: `%APPDATA%\.purple\plugins\` (for user-specific installation)

3. **Copy dependencies**: Make sure the following DLL files are in the same directory as Pidgin.exe or in your system PATH:
   - `libglib-2.0-0.dll`
   - `libgthread-2.0-0.dll`
   - `libpurple.dll`
   - `libtdjson.dll`

## Files Included

- `libtelegram-tdlib.dll` - The main Telegram plugin
- `libpurple.dll` - Purple library (may already exist in your Pidgin installation)
- `libglib-2.0-0.dll` - GLib library dependency
- `libgthread-2.0-0.dll` - GLib threading library
- `libtdjson.dll` - Telegram Database Library (TDLib)

## Setup

1. Start Pidgin
2. Go to **Accounts** → **Manage Accounts**
3. Click **Add**
4. Select **Telegram** from the protocol list
5. Enter your phone number (with country code, e.g., +1234567890)
6. Click **Add**
7. Pidgin will prompt you for the verification code sent to your phone
8. Enter the code and you should be connected to Telegram

## Features

- Send and receive text messages
- Group chats
- File transfers
- Stickers (basic support)
- Contact management
- Online/offline status

## Troubleshooting

- If the plugin doesn't appear in the protocol list, make sure all DLL files are in the correct location
- Check that you have the latest version of Pidgin installed
- Ensure your phone number is entered with the correct country code
- If you encounter connection issues, check your internet connection and firewall settings

## Notes

- This plugin uses the official Telegram API through TDLib
- Your Telegram account will show as "Pidgin" in the active sessions
- Some advanced Telegram features may not be available through this plugin

## Support

For issues and support, please visit the original project repository:
https://github.com/BenWiederhake/tdlib-purple

## Version Information

- Built with TDLib version: Latest
- Compatible with Pidgin 2.13.0 and later
- Windows 32-bit build
