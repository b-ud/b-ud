#!/bin/bash

# Script to replace /etc/login.defs with a custom file

# Define variables
SOURCE_FILE="namedlogin-defs.txt"
TARGET_FILE="/etc/login.defs"
BACKUP_FILE="/etc/login.defs.bak"

# Check if the source file exists
if [[ ! -f "$SOURCE_FILE" ]]; then
    echo "Error: Source file $SOURCE_FILE does not exist."
    exit 1
fi

# Backup the existing /etc/login.defs if it exists
if [[ -f "$TARGET_FILE" ]]; then
    echo "Backing up existing $TARGET_FILE to $BACKUP_FILE..."
    sudo cp "$TARGET_FILE" "$BACKUP_FILE" || {
        echo "Failed to create backup. Aborting."; exit 1;
    }
    echo "Backup created at $BACKUP_FILE."
fi

# Replace the target file with the source file
echo "Replacing $TARGET_FILE with $SOURCE_FILE..."
sudo cp "$SOURCE_FILE" "$TARGET_FILE" || {
    echo "Failed to replace $TARGET_FILE. Aborting."; exit 1;
}

echo "$TARGET_FILE successfully replaced with $SOURCE_FILE."

# End of script
echo "Operation completed."
