#!/bin/bash

# Function to prompt user for deletion
delete_item() {
    local item="$1"
    read -p "Delete $item? (y/n): " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        if [[ -f "$item" ]]; then
            rm -f "$item" && echo "$item deleted."
        elif [[ -d "$item" ]]; then
            rm -rf "$item" && echo "$item directory deleted."
        fi
    else
        echo "$item skipped."
    fi
}

# Search and prompt for MP3 files
find / -type f -name "*.mp3" 2>/dev/null | while read -r file; do
    echo "MP3 file found: $file"
    delete_item "$file"
done

# Patterns for malicious or unwanted files and software
MALICIOUS_PATTERNS=(
    "*crack*"
    "*hack*"
    "*keygen*"
    "*malware*"
    "*spyware*"
    "*.exe"
    "*.bat"
    "*.scr"
    "*.torrent"
    "*.iso"
    "*.apk"
    "*game*"
)

# Search for malicious or unwanted files
for pattern in "${MALICIOUS_PATTERNS[@]}"; do
    find / -type f -iname "$pattern" 2>/dev/null | while read -r file; do
        echo "Suspicious file found: $file"
        delete_item "$file"
    done
done

# Check for installed suspicious software using dpkg
echo "Checking installed software..."
dpkg -l | grep -E "nmap|metasploit|hydra|john|aircrack-ng|sqlmap|ettercap|wireshark|game|hack|crack|torrent|malware" | while read -r line; do
    package=$(echo "$line" | awk '{print $2}')
    echo "Suspicious software found: $package"
    read -p "Do you want to uninstall $package? (y/n): " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        sudo apt-get remove --purge -y "$package" && echo "$package uninstalled."
    else
        echo "$package not uninstalled."
    fi

done

# End of script
echo "File and software management script completed."
