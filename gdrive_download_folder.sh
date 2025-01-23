#!/bin/bash
#
# Function to detect the package manager and the distribution
detect_package_manager() {
    if [ -f /etc/os-release ]; then
        # Get the name of the distribution
        DISTRO_NAME=$(grep ^ID= /etc/os-release | cut -d= -f2 | tr -d '"')

        case "$DISTRO_NAME"
            ubuntu|debian|pop) in
                PACKAGE_MANAGER="apt"
                INSTALL_CMD="sudo apt install gdrive"
                ;;
            arch|manjaro)
                PACKAGE_MANAGER="pacman"
                INSTALL_CMD="sudo pacman -S gdrive"
                ;;
            fedora)
                PACKAGE_MANAGER="dnf"
                INSTALL_CMD="sudo dnf install gdrive"
                ;;
            centos|rhel)
                PACKAGE_MANAGER="yum"
                INSTALL_CMD="sudo yum install gdrive"
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

# Function to install yay on Arch-based distros
install_yay() {
    echo "Attempting to install yay (AUR helper) to install gdrive..."
    # Installing yay from the AUR
    sudo pacman -S --needed base-devel git
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    cd ..
    rm -rf yay
}

# Function to install gdrive from source (for unsupported distros)
install_from_source() {
    echo "Installing gdrive from source..."

    # Dependencies for building gdrive from source
    sudo apt update
    sudo apt install -y git go

    # Clone the gdrive repository and build it
    git clone https://github.com/prasmussen/gdrive.git
    cd gdrive
    go get -u github.com/prasmussen/gdrive
    go build

    # Move the binary to a directory in PATH
    sudo mv gdrive /usr/local/bin/

    cd ..
    rm -rf gdrive

    echo "gdrive has been installed from source."
}

# Check if gdrive is installed, if not, try to install it
if ! command -v gdrive &> /dev/null
then
    echo "gdrive not found, checking package manager..."
    
    # Detect the appropriate package manager
    detect_package_manager

    if [ "$PACKAGE_MANAGER" != "unknown" ]; then
        echo "Attempting to install gdrive using $PACKAGE_MANAGER..."
        # For pacman, try to install yay first
        if [ "$PACKAGE_MANAGER" == "pacman" ]; then
            install_yay
            yay -S gdrive
        else
            $INSTALL_CMD
        fi
    else
        # If distro is unsupported, try compiling from source
        install_from_source
    fi

    # Check if gdrive was installed
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

# Download the Google Drive folder using gdrive
gdrive download --recursive "$folder_id" -p "$local_folder"
