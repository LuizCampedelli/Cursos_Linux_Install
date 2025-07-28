# Cursor AI IDE Linux Installation Script

This repository contains a Bash script to automate the installation of Cursor AI IDE on Linux systems, specifically focusing on the AppImage distribution. The script aims to be user-friendly and generic, handling common setup tasks like placing the AppImage, creating a desktop entry, and setting up an AppArmor profile for proper labeling.

## Features

* **Generic AppImage Location:** Asks the user for the AppImage filename in their `Downloads` folder, making it flexible for various download names (e.g., `Cursor-1.2.1-x86_64.AppImage`).
* **Standard Installation Path:** Copies the AppImage to `/opt/cursor.appimage` for system-wide access.
* **Desktop Integration:** Creates a `.desktop` file (`/usr/share/applications/cursor.desktop`) to integrate Cursor AI IDE into your application menu.
* **Icon Download:** Downloads the Cursor icon and places it at `/opt/cursor.png`.
* **AppArmor Profile:** Creates and loads a basic AppArmor profile (`/etc/apparmor.d/cursor-appimage`) to label the running AppImage process as "cursor," improving system oversight.
* **Error Handling:** Includes checks for dependencies (like `curl`) and provides informative messages for successful steps or encountered errors.
* **Cleanup:** Removes the original AppImage from the user's `Downloads` folder after successful installation.

## Prerequisites

Before running the script, ensure you have:

* **A Linux system (Debian/Ubuntu-based recommended)** where `apt-get` and `sudo` are available.
* **`curl`**: Used for downloading the icon. The script attempts to install it if missing.
* **`xdg-user-dir`**: (Part of `xdg-user-dirs`) Used to reliably locate the user's Downloads directory. Most desktop Linux distributions include this by default.
* **`apparmor` and `apparmor-utils`**: These packages are necessary for AppArmor functionality. The script will check for `apparmor_parser`. If AppArmor is not installed, the profile creation/loading step will warn you but the installation will proceed.
    ```bash
    sudo apt-get update
    sudo apt-get install -y apparmor apparmor-utils # Install if needed
    ```
* **Downloaded Cursor AppImage:** You must have the Cursor AI IDE AppImage file already downloaded into your user's `Downloads` directory. You can get it from the official Cursor website's [downloads page](https://cursor.com/downloads).
    * **Note:** At the time of this README creation (July 2025), the primary AppImage for Linux is typically `x64`.

## Usage

1.  **Clone this repository or download the script:**

    ```bash
    git clone [https://github.com/LuizCampedelli/cursor-linux-install.git](https://github.com/LuizCampedelli/cursor-linux-install.git)
    cd cursor-linux-install
    ```
    (Replace `YOUR_USERNAME` with your GitHub username if you fork it)

    Alternatively, just download the `installCursor.sh` script directly.

2.  **Make the script executable:**

    ```bash
    chmod +x installCursor.sh
    ```

3.  **Run the script:**

    ```bash
    ./installCursor.sh
    ```

4.  **Follow the prompts:** The script will ask you to enter the full filename of the Cursor AppImage located in your `Downloads` folder. For example, if your downloaded file is named `Cursor-1.2.1-x86_64.AppImage`, type that in.

### Example Output (Successful Installation)