#!/bin/bash
# Script to reassemble the Windows build from split parts

echo "Reassembling telegram-pidgin-plugin-windows.zip..."

# Check if all parts exist
if [ ! -f "windows-build-part-aa" ] || [ ! -f "windows-build-part-ab" ] || [ ! -f "windows-build-part-ac" ] || [ ! -f "windows-build-part-ad" ]; then
    echo "Error: Missing split parts. Please ensure all parts (aa, ab, ac, ad) are present."
    exit 1
fi

# Reassemble the file
cat windows-build-part-aa windows-build-part-ab windows-build-part-ac windows-build-part-ad > telegram-pidgin-plugin-windows.zip

# Verify the file
if [ -f "telegram-pidgin-plugin-windows.zip" ]; then
    echo "✅ Successfully reassembled telegram-pidgin-plugin-windows.zip"
    echo "📦 File size: $(du -h telegram-pidgin-plugin-windows.zip | cut -f1)"
    echo ""
    echo "🚀 Next steps:"
    echo "1. Extract the zip file"
    echo "2. Copy all DLL files to your Pidgin plugins directory"
    echo "3. Restart Pidgin"
    echo "4. Add Telegram account"
    echo ""
    echo "📁 Default Pidgin plugins directory:"
    echo "   C:\\Program Files (x86)\\Pidgin\\plugins\\"
    echo "   or"
    echo "   %APPDATA%\\.purple\\plugins\\"
else
    echo "❌ Error: Failed to reassemble the file"
    exit 1
fi
