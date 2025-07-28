#!/bin/bash

installCursor() {
    # Define installation paths and filenames
    INSTALL_DIR="/opt"
    APPIMAGE_NAME="cursor.appimage" # Standard name for the installed appimage
    INSTALLED_APPIMAGE_PATH="$INSTALL_DIR/$APPIMAGE_NAME"
    ICON_URL="https://raw.githubusercontent.com/rahuljangirwork/copmany-logos/refs/heads/main/cursor.png"
    ICON_PATH="$INSTALL_DIR/cursor.png"
    DESKTOP_ENTRY_PATH="/usr/share/applications/cursor.desktop"
    APP_PROFILE_PATH="/etc/apparmor.d/cursor-appimage" # Path for the AppArmor profile

    # Get the current user's home directory
    USER_HOME_DIR="$HOME"

    # Get the user's Downloads directory using xdg-user-dir
    if command -v xdg-user-dir &> /dev/null; then
        USER_DOWNLOADS_DIR=$(xdg-user-dir DOWNLOAD 2>/dev/null)
        if [ -z "$USER_DOWNLOADS_DIR" ]; then
            USER_DOWNLOADS_DIR="$USER_HOME_DIR/Downloads"
        fi
    else
        USER_DOWNLOADS_DIR="$USER_HOME_DIR/Downloads"
    fi

    echo "Detected user's home directory: $USER_HOME_DIR"
    echo "Detected user's Downloads directory: $USER_DOWNLOADS_DIR"

    if ! [ -f "$INSTALLED_APPIMAGE_PATH" ]; then
        echo "Installing Cursor AI IDE..."

        # Check for curl (still good to have for icon download)
        if ! command -v curl &> /dev/null; then
            echo "curl is not installed. Installing..."
            sudo apt-get update
            sudo apt-get install -y curl
            if [ $? -ne 0 ]; then
                echo "Error: Failed to install curl. Exiting."
                return 1
            fi
        fi

        # Prompt user for the AppImage filename
        read -p "Please enter the full filename of the Cursor AppImage in your Downloads folder (e.g., Cursor-1.2.3-x86_64.AppImage): " DOWNLOADED_APPIMAGE_FILENAME

        DOWNLOADED_APPIMAGE_PATH="$USER_DOWNLOADS_DIR/$DOWNLOADED_APPIMAGE_FILENAME"

        # Verify the AppImage exists in the Downloads folder
        if ! [ -f "$DOWNLOADED_APPIMAGE_PATH" ]; then
            echo "Error: The file '$DOWNLOADED_APPIMAGE_PATH' was not found."
            echo "Please ensure the filename is correct and the file is in your Downloads folder ($USER_DOWNLOADS_DIR)."
            return 1
        fi

        echo "Copying Cursor AppImage from '$DOWNLOADED_APPIMAGE_PATH' to '$INSTALLED_APPIMAGE_PATH'..."
        sudo cp "$DOWNLOADED_APPIMAGE_PATH" "$INSTALLED_APPIMAGE_PATH"
        if [ $? -ne 0 ]; then
            echo "Error: Failed to copy Cursor AppImage. Please check permissions."
            return 1
        fi

        echo "Making Cursor AppImage executable..."
        sudo chmod +x "$INSTALLED_APPIMAGE_PATH"
        if [ $? -ne 0 ]; then
            echo "Error: Failed to make Cursor AppImage executable. Please check permissions."
            return 1
        fi

        # Remove the original downloaded file to clean up
        echo "Removing original AppImage from Downloads folder..."
        rm "$DOWNLOADED_APPIMAGE_PATH" # No sudo needed as it's in user's folder

        # Download Cursor icon
        echo "Downloading Cursor icon from $ICON_URL to $ICON_PATH..."
        sudo curl -L "$ICON_URL" -o "$ICON_PATH"
        if [ $? -ne 0 ]; then
            echo "Warning: Failed to download Cursor icon. The application may not have an icon in the menu."
        fi

        # Create a .desktop entry for Cursor
        echo "Creating .desktop entry for Cursor at $DESKTOP_ENTRY_PATH..."
        sudo bash -c "cat > \"$DESKTOP_ENTRY_PATH\"" <<EOL
[Desktop Entry]
Name=Cursor AI IDE
Exec=$INSTALLED_APPIMAGE_PATH
Icon=$ICON_PATH
Type=Application
Categories=Development;
EOL
        if [ $? -ne 0 ]; then
            echo "Error: Failed to create .desktop entry. You might need to manually create it."
            return 1
        fi

        # --- AppArmor Profile Integration ---
        echo "Creating AppArmor profile for Cursor at $APP_PROFILE_PATH..."
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
        if [ $? -ne 0 ]; then
            echo "Error: Failed to create AppArmor profile. Skipping profile loading."
        else
            echo "Loading AppArmor profile..."
            sudo apparmor_parser -r "$APP_PROFILE_PATH"
            if [ $? -ne 0 ]; then
                echo "Error: Failed to load AppArmor profile. Cursor might run without specific AppArmor confinement, but should still function."
            else
                echo "AppArmor profile loaded successfully."
            fi
        fi
        # --- End AppArmor Profile Integration ---

        # Update desktop database after creating .desktop file and potentially AppArmor profile
        echo "Updating desktop database to refresh application menu..."
        sudo update-desktop-database
        if [ $? -ne 0 ]; then
            echo "Warning: Failed to update desktop database. You might need to log out and back in, or reboot, for Cursor to appear in the menu."
        fi

        echo "Cursor AI IDE installation complete. You can find it in your application menu."
    else
        echo "Cursor AI IDE is already installed at $INSTALLED_APPIMAGE_PATH."
    fi
}

installCursor