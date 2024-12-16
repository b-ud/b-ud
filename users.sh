#!/bin/bash

# Define the text files
USER_FILE="user.txt"
ADMIN_FILE="admin.txt"

# Define the common password
PASSWORD="Cyber123!"

# Function to change the password of a user
change_password() {
    echo "$1:$PASSWORD" | chpasswd
}

# Function to get user confirmation
confirm_action() {
    read -p "$1 (yes/no): " response
    case "$response" in
        [Yy][Ee][Ss]) return 0 ;;
        [Nn][Oo]) return 1 ;;
        *) echo "Invalid response. Please type 'yes' or 'no'."; confirm_action "$1" ;;
    esac
}

# Read the list of all valid users from both files
mapfile -t USERS < "$USER_FILE"
mapfile -t ADMINS < "$ADMIN_FILE"

# Combine both user lists into a single set (unique values)
ALL_USERS=("${USERS[@]}" "${ADMINS[@]}")

# Change passwords for all users in user.txt and admin.txt
for user in "${ALL_USERS[@]}"; do
    if id "$user" &>/dev/null; then
        change_password "$user"
        echo "Password for user $user has been updated."
    else
        echo "User $user does not exist in the system."
    fi
done

# Ensure all admins are in the sudo and admin groups
for admin in "${ADMINS[@]}"; do
    if id "$admin" &>/dev/null; then
        if confirm_action "Add $admin to the sudo and admin groups?"; then
            usermod -aG sudo,admin "$admin"
            echo "User $admin has been added to the sudo and admin groups."
        else
            echo "Skipped adding $admin to the sudo and admin groups."
        fi
    fi
done

# Check for other users in the sudo and admin groups and remove them if they are not in admin.txt
for user in $(getent group sudo admin | awk -F: '{print $4}' | tr ',' '\n' | sort | uniq); do
    if [[ ! " ${ADMINS[@]} " =~ " $user " ]]; then
        if confirm_action "Remove $user from the sudo and admin groups?"; then
            gpasswd -d "$user" sudo
            gpasswd -d "$user" admin
            echo "User $user has been removed from the sudo and admin groups."
        else
            echo "Skipped removing $user from the sudo and admin groups."
        fi
    fi
done

# Remove users from the system who are not listed in either user.txt or admin.txt, and have UID <= 1000
for system_user in $(awk -F: '($3 > 0 && $3 <= 1000) {print $1}' /etc/passwd); do
    if [[ ! " ${ALL_USERS[@]} " =~ " $system_user " ]]; then
        if confirm_action "Delete user $system_user from the system?"; then
            userdel -r "$system_user"
            echo "User $system_user has been removed from the system."
        else
            echo "Skipped deleting user $system_user."
        fi
    fi
done

echo "All operations are complete."
