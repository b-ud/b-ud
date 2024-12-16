#!/bin/bash

# Function to display all active and inactive services and prompt for action
list_services() {
    echo "Listing all services on the system..."
    systemctl list-unit-files --type=service | awk '{print $1}' | while read -r service; do
        if [[ "$service" == *.service ]]; then
            echo "Service: $service"
            read -p "Do you want to (s)tart, (r)estart, (e)nable, (d)isable, or (q)uit managing this service? " action
            case $action in
                s|S)
                    sudo systemctl start "$service" && echo "$service started." || echo "Failed to start $service."
                    ;;
                r|R)
                    sudo systemctl restart "$service" && echo "$service restarted." || echo "Failed to restart $service."
                    ;;
                e|E)
                    sudo systemctl enable "$service" && echo "$service enabled." || echo "Failed to enable $service."
                    ;;
                d|D)
                    sudo systemctl disable "$service" && echo "$service disabled." || echo "Failed to disable $service."
                    ;;
                q|Q)
                    echo "Exiting management for $service."
                    ;;
                *)
                    echo "Invalid option. Skipping $service."
                    ;;
            esac
        fi
    done
}

# Call the function
list_services

# End of script
echo "Service management script completed."
