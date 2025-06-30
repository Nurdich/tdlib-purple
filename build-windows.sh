#!/bin/bash
# Windows Cross-Compilation Build Script for telegram-tdlib
# This script builds the Telegram plugin for Pidgin on Windows using MinGW-w64

set -e

# Configuration
DEPS_DIR="$(pwd)/deps"
BUILD_DIR="$(pwd)/build-windows"
RELEASE_DIR="$(pwd)/release-windows"
MINGW_PREFIX="i686-w64-mingw32"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if MinGW-w64 is installed
check_mingw() {
    if ! command -v ${MINGW_PREFIX}-gcc &> /dev/null; then
        log_error "MinGW-w64 not found. Please install it first:"
        echo "  Ubuntu/Debian: sudo apt install mingw-w64 mingw-w64-tools"
        echo "  Fedora: sudo dnf install mingw64-gcc mingw64-gcc-c++"
        exit 1
    fi
    log_info "MinGW-w64 found: $(${MINGW_PREFIX}-gcc --version | head -n1)"
}

# Install required packages
install_dependencies() {
    log_info "Installing build dependencies..."
    
    # Check if we're on Ubuntu/Debian
    if command -v apt &> /dev/null; then
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
    else
        log_warn "Please install the following packages manually:"
        echo "  - MinGW-w64 cross-compiler"
        echo "  - CMake"
        echo "  - wget, unzip, zip"
        echo "  - gettext"
    fi
}

# Download and build OpenSSL
build_openssl() {
    log_info "Building OpenSSL for Windows..."
    
    mkdir -p "${DEPS_DIR}"
    cd "${DEPS_DIR}"
    
    if [ ! -d "openssl-3.0.15" ]; then
        wget -q https://www.openssl.org/source/openssl-3.0.15.tar.gz
        tar -xzf openssl-3.0.15.tar.gz
    fi
    
    cd openssl-3.0.15
    
    if [ ! -f "install/lib/libssl.a" ]; then
        ./Configure mingw --cross-compile-prefix=${MINGW_PREFIX}- \
            --prefix="$(pwd)/install" \
            no-shared \
            no-tests
        make -j$(nproc)
        make install_sw
    fi
    
    log_info "OpenSSL build completed"
}

# Download and build TDLib
build_tdlib() {
    log_info "Building TDLib for Windows..."
    
    cd "${DEPS_DIR}"
    
    if [ ! -d "td" ]; then
        git clone https://github.com/tdlib/td.git
        cd td
        git submodule update --init --recursive
    else
        cd td
    fi
    
    mkdir -p build
    cd build
    
    cmake -DCMAKE_SYSTEM_NAME=Windows \
          -DCMAKE_C_COMPILER=${MINGW_PREFIX}-gcc \
          -DCMAKE_CXX_COMPILER=${MINGW_PREFIX}-g++ \
          -DOPENSSL_FOUND=True \
          -DOPENSSL_SSL_LIBRARY="${DEPS_DIR}/openssl-3.0.15/install/lib/libssl.a;ws2_32" \
          -DOPENSSL_CRYPTO_LIBRARY="${DEPS_DIR}/openssl-3.0.15/install/lib/libcrypto.a;ws2_32" \
          -DOPENSSL_INCLUDE_DIR="${DEPS_DIR}/openssl-3.0.15/install/include" \
          -DZLIB_FOUND=1 \
          -DZLIB_LIBRARIES=/usr/${MINGW_PREFIX}/lib/libz.a \
          -DZLIB_INCLUDE_DIRS=/usr/${MINGW_PREFIX}/include \
          -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_CXX_FLAGS="-pthread" \
          -DCMAKE_C_FLAGS="-pthread" \
          ..
    
    make -j$(nproc)
    make install DESTDIR="${DEPS_DIR}/win32-dev/td"
    
    log_info "TDLib build completed"
}

# Download Windows dependencies
download_windows_deps() {
    log_info "Downloading Windows dependencies..."
    
    cd "${DEPS_DIR}"
    
    # Download GTK development libraries
    if [ ! -d "win32-dev/gtk_2_0-2.14" ]; then
        mkdir -p win32-dev
        wget -q https://ftp.gnome.org/pub/gnome/binaries/win32/gtk+/2.24/gtk+-bundle_2.24.10-20120208_win32.zip
        unzip -q gtk+-bundle_2.24.10-20120208_win32.zip -d win32-dev/gtk_2_0-2.14
    fi
    
    # Download Pidgin Windows binaries for libpurple
    if [ ! -d "pidgin-2.13.0-win32bin" ]; then
        wget -q https://sourceforge.net/projects/pidgin/files/Pidgin/2.13.0/pidgin-2.13.0-win32-bin.zip
        unzip -q pidgin-2.13.0-win32-bin.zip
    fi
    
    # Create libpurple import library
    create_libpurple_import_lib
    
    log_info "Windows dependencies downloaded"
}

# Create libpurple import library
create_libpurple_import_lib() {
    log_info "Creating libpurple import library..."
    
    cd "${DEPS_DIR}/pidgin-2.13.0-win32bin"
    
    # Create a comprehensive export list for libpurple
    cat > libpurple_exports.def << 'EOF'
EXPORTS
purple_account_get_alias
purple_account_get_bool
purple_account_get_connection
purple_account_get_name_for_display
purple_account_get_protocol_id
purple_account_get_string
purple_account_get_username
purple_account_is_connected
purple_account_option_bool_new
purple_account_option_list_new
purple_account_option_string_new
purple_account_set_alias
purple_account_set_string
purple_accounts_find
purple_blist_add_account
purple_blist_add_buddy
purple_blist_add_chat
purple_blist_alias_buddy
purple_blist_alias_chat
purple_blist_find_chat
purple_blist_get_root
purple_blist_node_get_first_child
purple_blist_node_get_sibling_next
purple_blist_node_get_string
purple_blist_node_get_type
purple_blist_node_remove_setting
purple_blist_node_set_string
purple_blist_remove_account
purple_blist_remove_buddy
purple_blist_remove_chat
purple_buddy_get_account
purple_buddy_get_alias
purple_buddy_get_name
purple_buddy_icons_node_set_custom_icon
purple_buddy_icons_set_for_user
purple_buddy_new
purple_chat_get_account
purple_chat_get_components
purple_chat_get_name
purple_chat_new
purple_cmd_register
purple_connection_error
purple_connection_get_account
purple_connection_get_protocol_data
purple_connection_get_state
purple_connection_set_protocol_data
purple_connection_set_state
purple_connection_update_progress
purple_conv_chat_add_users
purple_conv_chat_clear_users
purple_conv_chat_get_conversation
purple_conv_chat_get_id
purple_conv_chat_has_left
purple_conv_chat_set_topic
purple_conv_chat_write
purple_conv_im_write
purple_conversation_get_account
purple_conversation_get_chat_data
purple_conversation_get_im_data
purple_conversation_get_name
purple_conversation_get_type
purple_conversation_get_ui_ops
purple_conversation_has_focus
purple_conversation_new
purple_conversation_present
purple_conversation_set_title
purple_conversation_write
purple_conversations_get_handle
purple_core_get_ui_info
purple_debug_info
purple_debug_is_enabled
purple_debug_is_verbose
purple_debug_misc
purple_debug_warning
purple_find_buddy
purple_find_conversation_with_account
purple_find_group
purple_group_get_name
purple_imgstore_add_with_id
purple_imgstore_find_by_id
purple_imgstore_get_data
purple_imgstore_get_size
purple_markup_escape_text
purple_markup_strip_html
purple_menu_action_new
purple_notify_message
purple_notify_user_info_add_pair
purple_notify_user_info_add_section_break
purple_notify_user_info_get_entries
purple_notify_user_info_new
purple_notify_userinfo
purple_plugin_action_new
purple_plugin_register
purple_primitive_get_id_from_type
purple_prpl_got_user_status
purple_proxy_get_setup
purple_proxy_info_get_host
purple_proxy_info_get_password
purple_proxy_info_get_port
purple_proxy_info_get_type
purple_proxy_info_get_username
purple_request_action
purple_request_field_group_add_field
purple_request_field_group_new
purple_request_field_set_type_hint
purple_request_field_string_new
purple_request_field_string_set_masked
purple_request_fields
purple_request_fields_add_group
purple_request_fields_get_string
purple_request_fields_new
purple_request_input
purple_roomlist_field_new
purple_roomlist_new
purple_roomlist_ref
purple_roomlist_room_add
purple_roomlist_room_add_field
purple_roomlist_room_get_fields
purple_roomlist_room_new
purple_roomlist_set_fields
purple_roomlist_set_in_progress
purple_roomlist_unref
purple_serv_got_join_chat_failed
purple_signal_connect
purple_status_type_new_full
purple_str_size_to_units
purple_unescape_html
purple_user_dir
purple_xfer_cancel_local
purple_xfer_cancel_remote
purple_xfer_end
purple_xfer_error
purple_xfer_get_account
purple_xfer_get_bytes_sent
purple_xfer_get_local_filename
purple_xfer_get_remote_user
purple_xfer_get_size
purple_xfer_get_status
purple_xfer_get_type
purple_xfer_is_canceled
purple_xfer_new
purple_xfer_ref
purple_xfer_request
purple_xfer_request_accepted
purple_xfer_set_bytes_sent
purple_xfer_set_cancel_recv_fnc
purple_xfer_set_cancel_send_fnc
purple_xfer_set_completed
purple_xfer_set_end_fnc
purple_xfer_set_filename
purple_xfer_set_init_fnc
purple_xfer_set_size
purple_xfer_start
purple_xfer_unref
purple_xfer_update_progress
purple_xfer_write_file
serv_got_chat_in
serv_got_im
serv_got_joined_chat
serv_got_typing
serv_got_typing_stopped
EOF
    
    ${MINGW_PREFIX}-dlltool -D libpurple.dll -d libpurple_exports.def -l libpurple.dll.a
}

# Build the plugin
build_plugin() {
    log_info "Building telegram-tdlib plugin for Windows..."
    
    cd "$(dirname "${DEPS_DIR}")"  # Go back to project root
    
    mkdir -p "${BUILD_DIR}"
    cd "${BUILD_DIR}"
    
    cmake -DCMAKE_SYSTEM_NAME=Windows \
          -DCMAKE_C_COMPILER=${MINGW_PREFIX}-gcc \
          -DCMAKE_CXX_COMPILER=${MINGW_PREFIX}-g++ \
          -DTd_DIR="${DEPS_DIR}/win32-dev/td/usr/local/lib/cmake/Td" \
          -DCMAKE_SHARED_LINKER_FLAGS="-static-libgcc -static-libstdc++ -L${DEPS_DIR}/win32-dev/gtk_2_0-2.14/lib -L${DEPS_DIR}/pidgin-2.13.0-win32bin" \
          -DCMAKE_EXE_LINKER_FLAGS="-static-libgcc -static-libstdc++ -L${DEPS_DIR}/win32-dev/gtk_2_0-2.14/lib -L${DEPS_DIR}/pidgin-2.13.0-win32bin" \
          -DNoPkgConfig=True \
          -DNoWebp=True \
          -DNoVoip=True \
          -DNoTranslations=True \
          -DPurple_INCLUDE_DIRS="${DEPS_DIR}/pidgin-2.13.0/libpurple;${DEPS_DIR}/win32-dev/gtk_2_0-2.14/include/glib-2.0;${DEPS_DIR}/win32-dev/gtk_2_0-2.14/lib/glib-2.0/include" \
          -DPurple_LIBRARIES="${DEPS_DIR}/pidgin-2.13.0-win32bin/libpurple.dll.a;${DEPS_DIR}/win32-dev/gtk_2_0-2.14/lib/libglib-2.0.dll.a;${DEPS_DIR}/win32-dev/gtk_2_0-2.14/lib/libgthread-2.0.dll.a" \
          -DCMAKE_BUILD_TYPE=Release \
          ..
    
    make -j$(nproc)
    
    log_info "Plugin build completed"
}

# Create release package
create_release() {
    log_info "Creating release package..."
    
    cd "$(dirname "${DEPS_DIR}")"  # Go back to project root
    
    mkdir -p "${RELEASE_DIR}"
    
    # Copy main plugin
    cp "${BUILD_DIR}/libtelegram-tdlib.dll" "${RELEASE_DIR}/"
    
    # Copy dependencies
    cp "${DEPS_DIR}/pidgin-2.13.0-win32bin/libpurple.dll" "${RELEASE_DIR}/"
    cp "${DEPS_DIR}/win32-dev/gtk_2_0-2.14/bin/libglib-2.0-0.dll" "${RELEASE_DIR}/"
    cp "${DEPS_DIR}/win32-dev/gtk_2_0-2.14/bin/libgthread-2.0-0.dll" "${RELEASE_DIR}/"
    cp "${DEPS_DIR}/win32-dev/td/usr/local/bin/libtdjson.dll" "${RELEASE_DIR}/"
    
    # Create README
    create_readme
    
    # Create zip package
    zip -r telegram-pidgin-plugin-windows.zip release-windows/
    
    log_info "Release package created: telegram-pidgin-plugin-windows.zip"
}

# Create README file
create_readme() {
    cat > "${RELEASE_DIR}/README.md" << 'EOF'
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
EOF
}

# Main execution
main() {
    log_info "Starting Windows build for telegram-tdlib..."
    
    check_mingw
    install_dependencies
    build_openssl
    build_tdlib
    download_windows_deps
    build_plugin
    create_release
    
    log_info "Windows build completed successfully!"
    log_info "Release package: telegram-pidgin-plugin-windows.zip"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
