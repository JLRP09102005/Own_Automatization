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
    local -n unit="$1"

    print_info "To write more than 1 option: AddRequirement=req1,req2,req1" 1
    echo ""

    read -r -p "¿Configure Basics? (y/n) [y]: " user_response
    user_response="${user_response:-y}"
    if check_yes_no_response "$user_response"; then

        read -r -p "Add Description [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("Description=$user_response")

        read -r -p "Add Documentation [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("Documentation=$user_response")

    fi

    read -r -p "¿Configure Start Up Dependencies? (y/n) [n]: " user_response
    user_response="${user_response:-n}"
    if check_yes_no_response "$user_response"; then

        read -r -p "Add Requirement [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("Requires=$user_response")

        read -r -p "Add Overridable Requirement [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("RequiresOverridable=$user_response")

        read -r -p "Add Requisite [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("Requisite=$user_response")

        read -r -p "Add Requisite Overridable [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("RequisiteOverridable=$user_response")

        read -r -p "Add Wants [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("Wants=$user_response")

        read -r -p "Add Binds To [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("BindsTo=$user_response")

        read -r -p "Add Part Of [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("PartOf=$user_response")

        read -r -p "Add Requires Mounts For [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("RequiresMountsFor=$user_response")

        read -r -p "Add Joins Namespace Of [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("JoinsNamespaceOf=$user_response")

        read -r -p "Add Conflicts [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("Conflicts=$user_response")

    fi

    read -r -p "¿Add Execution Orders? (y/n) [n]: " user_response
    if check_yes_no_response "$user_response"; then

        read -r -p "Add Before [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("Before=$user_response")

        read -r -p "Add After [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("After=$user_response")

        read -r -p "Add On Failure [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("OnFailure=$user_response")

        read -r -p "Add On Failure Job Mode [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("OnFailureJobMode=$user_response")

    fi

    read -r -p "¿Add Propagation Of Changes? (y/n) [n]: " user_response
    if check_yes_no_response "$user_response"; then

        read -r -p "Add Propagates Reload To [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("PropagatesReloadTo=$user_response")

        read -r -p "Add Reload Propagated From [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("ReloadPropagatedFrom=$user_response")

    fi

    read -r -p "¿Add Startup Conditions (FILE SYSTEM)? (y/n) [n]: " user_response
    if check_yes_no_response "$user_response"; then

        read -r -p "Add Condition Path Exists [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("ConditionPathExists=$user_response")

        read -r -p "Add Condition Path Exists Glob [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("ConditionPathExistsGlob=$user_response")

        read -r -p "Add Condition Path Is Directory [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("ConditionPathIsDirectory=$user_response")

        read -r -p "Add Condition Path Is Symbolic Link [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("ConditionPathIsSymbolicLink=$user_response")

        read -r -p "Add Condition Path Is Mount Point [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("ConditionPathIsMountPoint=$user_response")

        read -r -p "Add Condition Directory Not Empty [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("ConditionDirectoryNotEmpty=$user_response")

        read -r -p "Add Condition File Not Empty [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("ConditionFileNotEmpty=$user_response")

        read -r -p "Add Condition File Is Executable [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("ConditionFileIsExecutable=$user_response")

    fi

    read -r -p "¿Add Startup Conditions (SYSTEM)? (y/n) [n]: " user_response
    if check_yes_no_response "$user_response"; then

        read -r -p "Add Condition Architecture [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("ConditionArchitecture=$user_response")

        read -r -p "Add Condition Virtualization [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("ConditionVirtualization=$user_response")

        read -r -p "Add Condition Security [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("ConditionSecurity=$user_response")

        read -r -p "Add Condition Capability [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("ConditionCapability=$user_response")

        read -r -p "Add Condition Kernel Command Line [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("ConditionKernelCommandLine=$user_response")

        read -r -p "Add Condition AC Power [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("ConditionACPower=$user_response")

        read -r -p "Add Condition Needs Update [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("ConditionNeedsUpdate=$user_response")

        read -r -p "Add Condition Null [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("ConditionNull=$user_response")

    fi

    read -r -p "¿Add Startup Conditions (USER/ENVIRONMENT)? (y/n) [n]: " user_response
    if check_yes_no_response "$user_response"; then

        read -r -p "Add Condition User [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("ConditionUser=$user_response")

        read -r -p "Add Condition Group [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("ConditionGroup=$user_response")

        read -r -p "Add Condition Environment [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("ConditionEnvironment=$user_response")

        read -r -p "Add Condition Form Field [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("ConditionFormField=$user_response")

        read -r -p "Add Condition Extension [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("ConditionExtension=$user_response")

    fi

    read -r -p "¿Add Manual Activation Control? (y/n) [n]: " user_response
    if check_yes_no_response "$user_response"; then

        read -r -p "Add Refuse Manual Start [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("RefuseManualStart=$user_response")

        read -r -p "Add Refuse Manual Stop [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("RefuseManualStop=$user_response")

        read -r -p "Add Refuse Manual Reload [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("RefuseManualReload=$user_response")

        read -r -p "Allow Isolate [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("AllowIsolate=$user_response")

    fi

    read -r -p "¿Add System Behavior? (y/n) [n]: " user_response
    if check_yes_no_response "$user_response"; then

        read -r -p "Add Default Dependencies [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("DefaultDependencies=$user_response")

        read -r -p "Add Stop When Unneeded [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("StopWhenUnneeded=$user_response")

        read -r -p "Add Ignore On Isolate [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("IgnoreOnIsolate=$user_response")

        read -r -p "Add Ignore On Snapshot [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("IgnoreOnSnapshot=$user_response")

        read -r -p "Add CollectMode [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("CollectMode=$user_response")

    fi

    read -r -p "¿Add Timeouts & Actions? (y/n) [n]: " user_response
    if check_yes_no_response "$user_response"; then

        read -r -p "Add Job Timeout Sec [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("JobTimeoutSec=$user_response")

        read -r -p "Add Job Timeout Action [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("JobTimeoutAction=$user_response")

        read -r -p "Add Job Timeout Reboot Arg [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("JobTimeoutRebootArg=$user_response")

    fi

    read -r -p "¿Add Debugging? (y/n) [n]: " user_response
    if check_yes_no_response "$user_response"; then

        read -r -p "Add Source Path [ENTER to skip]: " user_response
        [[ -n "$user_response" ]] && unit+=("SourcePath=$user_response")

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