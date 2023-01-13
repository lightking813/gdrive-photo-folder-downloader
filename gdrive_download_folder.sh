#!/bin/bash

# Check if gdrive is installed, if not, install it
if ! command -v gdrive &> /dev/null
then
    sudo pacman -S gdrive
fi

# Ask the user for the Google Drive folder ID
read -p "Enter the Google Drive folder ID: " folder_id

# Define the local destination for the downloaded folder
local_folder="$HOME/Pictures"

# Download the Google Drive folder using gdrive
gdrive download --recursive $folder_id -p $local_folder
