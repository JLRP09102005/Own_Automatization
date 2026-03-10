#!/bin/bash

#====== SHELL VARIABLES ======
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
option=-1
tables=(filter)
root_user=0

#====== SOURCE FILES ======
source "$BASE_DIR/file-utils.sh"
source "$UTILS_SCRIPT"
source "$IPTABLES_SCRIPT"
source "$SERVICE_SCRIPT"

#====== FUNCTIONS ======
main_menu()
{
    while [ "$option" -ne 0 ]; do
        clear
        print_main_menu

        read -r -p "Select Option: " option

        if ! check_only_numbers "$option"; then
            print_error "Make sure that you selected a correct option" 2
            option=-1
            continue
        fi

        if [ "$option" -eq 1 ]; then
            clean_menu
        elif [ "$option" -eq 2 ]; then
            rules_menu
        elif [ "$option" -eq 3 ]; then
            services_menu
        elif [ "$option" -eq 4 ]; then
            show_iptables_service_state
        elif [ "$option" -eq 5 ]; then
            save_service_file
            save_iptables_file
        fi

    done

    print_info "Exiting"
    sleep 2
}

clean_menu()
{
    while [ "$option" -ne 0 ]; do
        clear
        print_clean_menu

        read -r -p "Select Option: " option

        if ! check_only_numbers "$option"; then
            print_error "Make sure that you selected a correct option" 2
            option=-1
            continue
        fi

        if [ "$option" -eq 1 ]; then
            print_info "Adding cleaning tables commands..." 2
            iptables_clean_all_rules
        elif [ "$option" -eq 2 ]; then
            print_info "2" 2
        elif [ "$option" -eq 3 ]; then
            print_info "3" 2
        fi

    done

    option=-1
}

rules_menu()
{
    while [ "$option" -ne 0 ]; do
        clear
        print_rules_menu

        read -r -p "Select Option: " option

        if ! check_only_numbers "$option"; then
            print_error "Make sure that you selected a correct option" 2
            option=-1
            continue
        fi

        if [ "$option" -eq 1 ]; then
            print_info "Adding default rules commands..." 2
            iptables_default_rules
        elif [ "$option" -eq 2 ]; then
            print_info "2" 2
        elif [ "$option" -eq 3 ]; then
            iptables_rule_wizzard
        fi

    done

    option=-1
}

services_menu()
{
    while [ "$option" -ne 0 ]; do
        clear
        print_services_menu

        read -r -p "Select Option: " option

        if ! check_only_numbers "$option"; then
            print_error "Make sure that you selected a correct option" 2
            option=-1
            continue
        fi

        if [ "$option" -eq 1 ]; then
            echo "call files function"
        elif [ "$option" -eq 2 ]; then
            create_default_service
        elif [ "$option" -eq 3 ]; then
            create_service_wizzard
        elif [ "$option" -eq 4 ]; then
            echo "option 4"
        elif [ "$option" -eq 5 ]; then
            start_iptables_service
        elif [ "$option" -eq 6 ]; then
            stop_iptables_service
        elif [ "$option" -eq 7 ]; then
            enable_iptables_service
        elif [ "$option" -eq 8 ]; then
            disable_iptables_service
        elif [ "$option" -eq 9 ]; then
            print_iptables_service_file
        fi
    done

    option=-1
}

#Checks if the user who exeuted the script has root privilegies
check_root_privilegies

#Check if exists iptables file, if exists clean it, if not create it
reset_sys_file

#Check if exists service file, if exists clean it, if not create it
# reset_service_file

#Starts the program
main_menu