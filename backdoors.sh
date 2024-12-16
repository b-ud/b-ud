#!/bin/bash

# Function to display warning for potential backdoors
function warning() {
    echo -e "\n[!] Potential Backdoor Detected:"
    echo -e "PID: $1 | Port: $2 | UID: $3 | Process: $4 | Path: $5\n"
}

# Function to confirm and kill the process
function kill_process() {
    local pid=$1
    read -p "Do you want to kill this process? (y/n): " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        kill -9 "$pid" && echo "Process $pid has been terminated."
    else
        echo "Process $pid was not terminated."
    fi
}

# Inform the user
echo "Scanning for potential backdoors on ALL ports..."

# Loop through all open ports and processes
while read -r line; do
    # Extract details from ss output
    pid=$(echo "$line" | awk '{print $7}' | cut -d'/' -f1)
    port=$(echo "$line" | awk '{print $4}' | awk -F: '{print $NF}')
    process=$(ps -p "$pid" -o comm= 2>/dev/null)
    path=$(readlink -f /proc/"$pid"/exe 2>/dev/null)
    uid=$(ps -o uid= -p "$pid" 2>/dev/null)

    # Skip processes without valid information
    if [[ -z "$pid" || -z "$process" || -z "$path" ]]; then
        continue
    fi

    # Check for unusual processes:
    # - bash-like processes listening on a port
    # - binaries running from non-standard locations
    if [[ "$process" == "bash" || "$process" == "sh" || ! "$path" =~ ^/usr/bin|/usr/sbin|/bin|/sbin ]]; then
        warning "$pid" "$port" "$uid" "$process" "$path"
        kill_process "$pid"
    fi
done < <(ss -tulnp | tail -n +2)

echo -e "\nScan complete."
