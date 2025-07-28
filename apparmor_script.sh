#!/bin/bash

# Define the path where the AppArmor profile will be created
APP_PROFILE_PATH="/etc/apparmor.d/cursor-appimage"
# Define the path to the installed Cursor AppImage
# IMPORTANT: This script assumes Cursor is already installed here.
INSTALLED_APPIMAGE_PATH="/opt/cursor.appimage"

echo "Attempting to add AppArmor profile for Cursor AI IDE..."

# Check if apparmor_parser is available
if ! command -v apparmor_parser &> /dev/null; then
    echo "Error: apparmor_parser not found. AppArmor might not be installed or configured on your system."
    echo "Please install AppArmor (e.g., sudo apt-get install apparmor apparmor-utils) and try again."
    exit 1
fi

# Check if the target AppImage exists, as the profile will refer to it.
if ! [ -f "$INSTALLED_APPIMAGE_PATH" ]; then
    echo "Warning: Cursor AppImage not found at '$INSTALLED_APPIMAGE_PATH'."
    echo "The AppArmor profile will be created, but it might not apply correctly if the application path is wrong."
    echo "Please ensure Cursor is installed before running this script, or adjust INSTALLED_APPIMAGE_PATH."
fi

# Create the AppArmor profile file
echo "Creating AppArmor profile for Cursor at '$APP_PROFILE_PATH'..."
sudo bash -c "cat > \"$APP_PROFILE_PATH\"" <<'APP_PROFILE_EOL'
# This profile allows everything and only exists to give the
# application a name instead of having the label "unconfined"

abi <abi/4.0>,
include <tunables/global>

profile cursor /opt/cursor.appimage flags=(unconfined) {
  userns,

  # Site-specific additions and overrides.  See local/README for details.
  include if exists <local/cursor>
}
APP_PROFILE_EOL

# Check if the profile file creation was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to create AppArmor profile file. Check permissions or disk space."
    exit 1
fi

# Load the AppArmor profile into the kernel
echo "Loading AppArmor profile into the kernel..."
sudo apparmor_parser -r "$APP_PROFILE_PATH"

# Check if loading the profile was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to load AppArmor profile. AppArmor might be misconfigured or the syntax is invalid."
    echo "You can check system logs for more details (e.g., journalctl -xe or dmesg)."
    exit 1
else
    echo "AppArmor profile for Cursor loaded successfully."
    echo "New instances of Cursor AppImage will now run under the 'cursor' AppArmor label."
fi

exit 0