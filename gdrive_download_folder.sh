#!/bin/bash

# Function to install gdrive from source (for unsupported distros)
install_from_source() {
    echo "Installing gdrive from source..."
    if command -v apt &> /dev/null; then
        sudo apt update
        sudo apt install -y git golang
    else
        echo "Unable to install dependencies. Please install Git and Go manually."
        exit 1
    fi

    # Clone the gdrive repository and build it
    git clone https://github.com/prasmussen/gdrive.git
    cd gdrive
    go get -u github.com/prasmussen/gdrive
    go build
    sudo mv gdrive /usr/local/bin/
    cd ..
    rm -rf gdrive
    echo "gdrive has been installed from source."
}

# Check if gdrive is installed, if not, try to install it
if ! command -v gdrive &> /dev/null; then
    echo "gdrive not found, checking package manager..."
    detect_package_manager

    if [ "$PACKAGE_MANAGER" != "unknown" ]; then
        echo "Attempting to install gdrive using $PACKAGE_MANAGER..."
        if [ "$PACKAGE_MANAGER" == "pacman" ]; then
            install_yay
            yay -S --noconfirm gdrive
        else
            eval "$INSTALL_CMD"
        fi
    else
        echo "Unsupported distribution. Attempting to install gdrive from source..."
        install_from_source
    fi

    if ! command -v gdrive &> /dev/null; then
        echo "gdrive could not be installed. Please install it manually."
        exit 1
    fi
fi

# Ask the user for the Google Drive folder ID
read -p "Enter the Google Drive folder ID: " folder_id

# Define the local destination for the downloaded folder
local_folder="$HOME/Pictures"

# Check if the destination folder exists
if [ ! -d "$local_folder" ]; then
    echo "The destination folder $local_folder does not exist. Creating it..."
    mkdir -p "$local_folder"
fi

echo "Ready to sync Google Drive folder $folder_id to $local_folder."
# Add your gdrive sync logic here if required.
then
exit
