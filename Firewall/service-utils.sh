#!/bin/bash

#====== SERVICE FUNCTIONS ======
##Service File Printer
print_service_file()
{
    echo "${FG_YELLOW}"
    cat "$SERVICE_FILE"
    echo "${NC}"
}

##Service Writer
# shellcheck disable=SC2120
write_service()
{
    if [ "$#" -gt 0 ]; then
        printf "%s\n" "$@" > "$SERVICE_FILE"
    else
        cat > "$SERVICE_FILE"
    fi
}

##Default Rule Creator
create_default_service()
{
    write_service << 'CONTENT'
[Unit]
Description=Service for iptables rules
After=network-online.target NetworkManager-wait-online-initrd.service NetworkManager.service
Wants=network-online.target
Before=graphical.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/bin/iptables-rules.sh
TimeoutStartSec=120
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
CONTENT
}

create_service_wizzard()
{
    local user_response service_file 
    local -a unit service install

    unit=("[Unit]")
    service=("[Service]")
    install=("[Install]")

    read -r -p "¿Configure [Unit]? (y/n) [n]: " user_response
    user_response="${user_response:-n}"
    if check_yes_no_response "$user_response"; then
        configure_unit_wizzard unit
    fi

    read -r -p "¿Configure [Service]? (y/n) [n]: " user_response
    if check_yes_no_response "$user_response"; then
        configure_service_wizzard service
    fi

    read -r -p "¿Configure [Install]? (y/n) [n]: " user_response
    if check_yes_no_response "$user_response"; then
        configure_install_wizzard install
    fi

    service_file=("${unit[@]}" "${install[@]}" "${service[@]}")
    write_service "${service_file[@]}"
}

configure_unit_wizzard()
{
    local -n arr="$1"
    local user_response

    print_info "To write more than 1 option: AddRequirement=req1,req2,req1" 1
    echo ""

    read -r -p "¿Configure Basics? (y/n) [y]: " user_response
    user_response="${user_response:-y}"
    if check_yes_no_response "$user_response"; then

        read -r -p "Add Description [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("Description=$user_response")

        read -r -p "Add Documentation [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("Documentation=$user_response")

    fi

    read -r -p "¿Configure Start Up Dependencies? (y/n) [n]: " user_response
    user_response="${user_response:-n}"
    if check_yes_no_response "$user_response"; then

        read -r -p "Add Requirement [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("Requires=$user_response")

        read -r -p "Add Overridable Requirement [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("RequiresOverridable=$user_response")

        read -r -p "Add Requisite [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("Requisite=$user_response")

        read -r -p "Add Requisite Overridable [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("RequisiteOverridable=$user_response")

        read -r -p "Add Wants [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("Wants=$user_response")

        read -r -p "Add Binds To [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("BindsTo=$user_response")

        read -r -p "Add Part Of [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("PartOf=$user_response")

        read -r -p "Add Requires Mounts For [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("RequiresMountsFor=$user_response")

        read -r -p "Add Joins Namespace Of [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("JoinsNamespaceOf=$user_response")

        read -r -p "Add Conflicts [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("Conflicts=$user_response")

    fi

    read -r -p "¿Add Execution Orders? (y/n) [n]: " user_response
    if check_yes_no_response "$user_response"; then

        read -r -p "Add Before [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("Before=$user_response")

        read -r -p "Add After [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("After=$user_response")

        read -r -p "Add On Failure [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("OnFailure=$user_response")

        read -r -p "Add On Failure Job Mode [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("OnFailureJobMode=$user_response")

    fi

    read -r -p "¿Add Propagation Of Changes? (y/n) [n]: " user_response
    if check_yes_no_response "$user_response"; then

        read -r -p "Add Propagates Reload To [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("PropagatesReloadTo=$user_response")

        read -r -p "Add Reload Propagated From [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("ReloadPropagatedFrom=$user_response")

    fi

    read -r -p "¿Add Startup Conditions (FILE SYSTEM)? (y/n) [n]: " user_response
    if check_yes_no_response "$user_response"; then

        read -r -p "Add Condition Path Exists [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("ConditionPathExists=$user_response")

        read -r -p "Add Condition Path Exists Glob [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("ConditionPathExistsGlob=$user_response")

        read -r -p "Add Condition Path Is Directory [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("ConditionPathIsDirectory=$user_response")

        read -r -p "Add Condition Path Is Symbolic Link [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("ConditionPathIsSymbolicLink=$user_response")

        read -r -p "Add Condition Path Is Mount Point [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("ConditionPathIsMountPoint=$user_response")

        read -r -p "Add Condition Directory Not Empty [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("ConditionDirectoryNotEmpty=$user_response")

        read -r -p "Add Condition File Not Empty [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("ConditionFileNotEmpty=$user_response")

        read -r -p "Add Condition File Is Executable [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("ConditionFileIsExecutable=$user_response")

    fi

    read -r -p "¿Add Startup Conditions (SYSTEM)? (y/n) [n]: " user_response
    if check_yes_no_response "$user_response"; then

        read -r -p "Add Condition Architecture [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("ConditionArchitecture=$user_response")

        read -r -p "Add Condition Virtualization [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("ConditionVirtualization=$user_response")

        read -r -p "Add Condition Security [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("ConditionSecurity=$user_response")

        read -r -p "Add Condition Capability [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("ConditionCapability=$user_response")

        read -r -p "Add Condition Kernel Command Line [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("ConditionKernelCommandLine=$user_response")

        read -r -p "Add Condition AC Power [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("ConditionACPower=$user_response")

        read -r -p "Add Condition Needs Update [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("ConditionNeedsUpdate=$user_response")

        read -r -p "Add Condition Null [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("ConditionNull=$user_response")

    fi

    read -r -p "¿Add Startup Conditions (USER/ENVIRONMENT)? (y/n) [n]: " user_response
    if check_yes_no_response "$user_response"; then

        read -r -p "Add Condition User [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("ConditionUser=$user_response")

        read -r -p "Add Condition Group [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("ConditionGroup=$user_response")

        read -r -p "Add Condition Environment [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("ConditionEnvironment=$user_response")

        read -r -p "Add Condition Form Field [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("ConditionFormField=$user_response")

        read -r -p "Add Condition Extension [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("ConditionExtension=$user_response")

    fi

    read -r -p "¿Add Manual Activation Control? (y/n) [n]: " user_response
    if check_yes_no_response "$user_response"; then

        read -r -p "Add Refuse Manual Start [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("RefuseManualStart=$user_response")

        read -r -p "Add Refuse Manual Stop [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("RefuseManualStop=$user_response")

        read -r -p "Add Refuse Manual Reload [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("RefuseManualReload=$user_response")

        read -r -p "Allow Isolate [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("AllowIsolate=$user_response")

    fi

    read -r -p "¿Add System Behavior? (y/n) [n]: " user_response
    if check_yes_no_response "$user_response"; then

        read -r -p "Add Default Dependencies [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("DefaultDependencies=$user_response")

        read -r -p "Add Stop When Unneeded [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("StopWhenUnneeded=$user_response")

        read -r -p "Add Ignore On Isolate [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("IgnoreOnIsolate=$user_response")

        read -r -p "Add Ignore On Snapshot [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("IgnoreOnSnapshot=$user_response")

        read -r -p "Add CollectMode [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("CollectMode=$user_response")

    fi

    read -r -p "¿Add Timeouts & Actions? (y/n) [n]: " user_response
    if check_yes_no_response "$user_response"; then

        read -r -p "Add Job Timeout Sec [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("JobTimeoutSec=$user_response")

        read -r -p "Add Job Timeout Action [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("JobTimeoutAction=$user_response")

        read -r -p "Add Job Timeout Reboot Arg [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("JobTimeoutRebootArg=$user_response")

    fi

    read -r -p "¿Add Debugging? (y/n) [n]: " user_response
    if check_yes_no_response "$user_response"; then

        read -r -p "Add Source Path [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && arr+=("SourcePath=$user_response")

    fi
}

configure_service_wizzard()
{
    echo "configure wizzard"
}

configure_install_wizzard()
{
    echo "configure wizzard"
}

#====== SERVICE STATE ======
start_iptables_service()
{
    local service_name

    if [ "$root_user" -ne 0 ]; then
        service_name="$(read_file_coincidencies "$CONFIG_SAVE" "servicename" "" 1 | cut -d "=" -f2)"
        systemctl --user start "$service_name"
    else
        service_name="$(read_file_coincidencies "$CONFIG_SAVE" "servicename" "" 1 | cut -d "=" -f2)"
        sudo systemctl start "$service_name"
    fi
}

stop_iptables_service()
{
    local service_name

    if [ "$root_user" -ne 0 ]; then
        service_name="$(read_file_coincidencies "$CONFIG_SAVE" "servicename" "" 1 | cut -d "=" -f2)"
        systemctl --user stop "$service_name"
    else
        service_name="$(read_file_coincidencies "$CONFIG_SAVE" "servicename" "" 1 | cut -d "=" -f2)"
        sudo systemctl stop "$service_name"
    fi
}

enable_iptables_service()
{
    local service_name
    
    if [ "$root_user" -ne 0 ]; then
        service_name="$(read_file_coincidencies "$CONFIG_SAVE" "servicename" "" 1 | cut -d "=" -f2)"
        systemctl --user enable "$service_name"
    else
        service_name="$(read_file_coincidencies "$CONFIG_SAVE" "servicename" "" 1 | cut -d "=" -f2)"
        systemctl --user enable "$service_name"
    fi
}

disable_iptables_service()
{
    local service_name

    if [ "$root_user" -ne 0 ]; then
        service_name="$(read_file_coincidencies "$CONFIG_SAVE" "servicename" "" 1 | cut -d "=" -f2)"
        systemctl --user disable "$service_name"
    else
        service_name="$(read_file_coincidencies "$CONFIG_SAVE" "servicename" "" 1 | cut -d "=" -f2)"
        sudo systemctl disable "$service_name"
    fi
}

print_iptables_service_file()
{
    local filename="iptables-rules"

    print_file "${SERVICE_FILES_DIR}${filename}.service"
}

show_iptables_service_state()
{
    local file file_absolute_path

    read -r -p "Enter the service name without extension: " file

    if [ "$root_user" -ne 0 ]; then
        file_absolute_path="${USER_SERVICE_SAVE}${file}.service"
        [[ -f "$file_absolute_path" ]] && systemctl --user status "$file_absolute_path"
    else
        file_absolute_path="${SYSTEM_SERVICE_SAVE}${file}.service"
        [[ -f "$file_absolute_path" ]] && sudo systemctl status "$file_absolute_path"
    fi
}

#====== SERVICE SAVE ======
save_service_file()
{
    local service_file="iptables-rules"

    if [[ ! -f "${SERVICE_FILES_DIR}${service_file}.service" ]]; then
        print_error "The entered service file doesn't exists" 2
        return 1
    fi

    if [ "$root_user" -ne 0 ]; then
        move_file "${SERVICE_FILES_DIR}${service_file}.service" "${USER_SERVICE_SAVE}${service_file}.service"
        print_direcoty "${USER_SERVICE_SAVE}"
    else
        move_file "${SERVICE_FILES_DIR}${service_file}.service" "${SYSTEM_SERVICE_SAVE}${service_file}.service"
        print_direcoty "${SYSTEM_SERVICE_SAVE}"
    fi
}