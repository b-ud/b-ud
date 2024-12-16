#!/bin/bash
# Define keywords and their negated variants to search for
keywords=("default authenticate" "netcat" "nc" "bash -i" "sh -i")
negated_keywords=("default !authenticate" "!default authenticate" "no default authenticate"
"disable default authenticate")
# Directories to exclude from search
exclude_dirs=("/proc" "/sys" "/dev" "/run" "/var/log/journal")
# Function to scan files
scan_files() {
local search_dir=$1
echo -e "\nScanning directory: $search_dir"
# Search for standard keywords
for keyword in "${keywords[@]}"; do
echo -e "\n[+] Searching for: '$keyword'"
grep -Rin --exclude-dir={"${exclude_dirs[*]}"} --exclude="*.log" "$keyword" "$search_dir"
2>/dev/null | while read -r line; do
file=$(echo "$line" | awk -F: '{print $1}')
line_number=$(echo "$line" | awk -F: '{print $2}')
content=$(echo "$line" | cut -d: -f3-)
echo -e "[!] Keyword found:\nFile: $file\nLine: $line_number\nContent: $content\n"
# Prompt for investigation
read -p "Do you want to view this file now? (y/n): " choice
if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
less "$file"
fi
done
done
# Search for negated keywords
for neg_keyword in "${negated_keywords[@]}"; do
echo -e "\n[+] Searching for negated keyword: '$neg_keyword'"
grep -Rin --exclude-dir={"${exclude_dirs[*]}"} --exclude="*.log" "$neg_keyword"
"$search_dir" 2>/dev/null | while read -r line; do
file=$(echo "$line" | awk -F: '{print $1}')
line_number=$(echo "$line" | awk -F: '{print $2}')
content=$(echo "$line" | cut -d: -f3-)
echo -e "[!] Negated keyword found:\nFile: $file\nLine: $line_number\nContent:
$content\n"
# Prompt for investigation
read -p "Do you want to view this file now? (y/n): " choice
if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
less "$file"
fi
done
done
}
# Main script
echo "=== Scanning System for Keywords and Negated Patterns ==="
# Ask for confirmation
read -p "This script will search the entire filesystem. Continue? (y/n): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
echo "Scan aborted."
exit 1
fi
# Run the scan starting from root
scan_files "/"
echo -e "\n=== Scan Complete ==="
