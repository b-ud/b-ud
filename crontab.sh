#!/bin/bash

# Define patterns that might indicate a suspicious or malicious cron job
suspicious_patterns=("nc" "curl" "wget" "bash -i" "sh -i" "python -c" "perl -e" "php -r" "reverse shell" "exec" "base64")

# Function to check and interactively delete suspicious lines in a file
check_and_edit_crontab_file() {
    file_path=$1
    echo "Checking $file_path for suspicious entries..."

    # Create a temporary file to store safe lines
    temp_file=$(mktemp)

    # Read through each line in the file
    while IFS= read -r line; do
        is_suspicious=false
        for pattern in "${suspicious_patterns[@]}"; do
            if [[ "$line" =~ $pattern ]]; then
                is_suspicious=true
                echo "Potentially suspicious line found in $file_path:"
                echo "$line"
                read -p "Do you want to delete this line? (y/n): " choice
                if [[ "$choice" == "y" ]]; then
                    echo "Deleting line..."
                else
                    echo "$line" >> "$temp_file"
                fi
                break
            fi
        done
        # If the line is not suspicious, keep it
        if [ "$is_suspicious" = false ]; then
            echo "$line" >> "$temp_file"
        fi
    done < "$file_path"

    # Replace the original file with the cleaned version
    sudo mv "$temp_file" "$file_path"
    sudo chmod 600 "$file_path"
}

echo "Starting interactive crontab check for suspicious lines only..."

# Check crontab files for each user
for user in $(cut -f1 -d: /etc/passwd); do
    crontab_path="/var/spool/cron/crontabs/$user"
    if [ -f "$crontab_path" ]; then
        echo "Checking crontab for user: $user"
        check_and_edit_crontab_file "$crontab_path"
    fi
done

# Check system-wide cron directories
system_cron_dirs=("/etc/cron.d" "/etc/cron.daily" "/etc/cron.hourly" "/etc/cron.monthly" "/etc/cron.weekly")
for dir in "${system_cron_dirs[@]}"; do
    echo "Checking directory: $dir"
    for file in "$dir"/*; do
        if [ -f "$file" ]; then
            echo "Checking file: $file"
            check_and_edit_crontab_file "$file"
        fi
    done
done

echo "Suspicious crontab lines check complete."
