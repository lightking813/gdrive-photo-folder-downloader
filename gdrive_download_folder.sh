#!/bin/bash
# Function to detect the package manager
detect_package_manager() {
    if [ -f /etc/os-release ]; then
        DISTRO_NAME=$(grep ^ID= /etc/os-release | cut -d= -f2 | tr -d '"')
        echo "Detected Distribution: $DISTRO_NAME"
        
        case "$DISTRO_NAME" in
            ubuntu|debian|pop)
                PACKAGE_MANAGER="apt"
                INSTALL_CMD="sudo apt update && sudo apt install -y gdrive"
                ;;
            arch|manjaro)
                PACKAGE_MANAGER="pacman"
                INSTALL_CMD="sudo pacman -S --noconfirm gdrive"
                ;;
            fedora)
                PACKAGE_MANAGER="dnf"
                INSTALL_CMD="sudo dnf install -y gdrive"
                ;;
            centos|rhel)
                PACKAGE_MANAGER="yum"
                INSTALL_CMD="sudo yum install -y gdrive"
                ;;
            *)
                PACKAGE_MANAGER="unknown"
                ;;
        esac
    else
        echo "Unable to detect the distribution."
        exit 1
    fi
}

# Function to install gdrive from source (for unsupported distros)
install_from_source() {
    echo "Installing gdrive from source... MAKE SURE YOU INSTALL GIT!!!!"
    else
        echo "Unable to install dependencies. Please install Git and Go manually."
        exit 1
    fi

    git clone https://github.com/prasmussen/gdrive.git
    cd gdrive
    go get -u github.com/prasmussen/gdrive
    go build
    sudo mv gdrive /usr/local/bin/
    cd ..
    rm -rf gdrive

    echo "gdrive has been installed from source."
}

# Ask the user for the Google Drive folder ID
read -p "Enter the Google Drive folder ID: " folder_id

# Define the local destination for the downloaded folder
local_folder="$HOME/Pictures"

# Check if the destination folder exists
if [ ! -d "$local_folder" ]; then
    echo "The destination folder $local_folder does not exist. Creating it..."
    mkdir -p "$local_folder"
fi

# Confirm to the user that the script is ready to sync
echo "Ready to sync Google Drive folder ID '$folder_id' to the local folder: $local_folder."

# Add your gdrive sync logic below
# For example, if you are syncing the folder using gdrive:
gdrive download --recursive --path "$local_folder" "$folder_id"

# Final message to confirm completion
echo "Sync completed. Files from Google Drive folder ID '$folder_id' are now available in $local_folder."

exit
