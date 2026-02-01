#!/bin/bash

#====== IPTABLES FUNCTIONS ======
##Rule Writer
write_rule()
{
    if [ "$#" -gt 0 ]; then
        printf "$@" >> "$SYS_FILE"
    else
        cat >> "$SYS_FILE"
    fi
}

##Clean Rules
iptables_clean_all_rules()
{
    write_rule << 'CONTENT'
#Clean All Firewall Rules
tables=(filter nat mangle raw security)
#====== DEFAULT POLICY ======
for table in "${tables[@]}"; do

    #default policies ipv4
    iptables -w 10 -t "$table" -P OUTPUT DROP >"/dev/null" 2>&1
    iptables -w 10 -t "$table" -P INPUT DROP >"/dev/null" 2>&1
    iptables -w 10 -t "$table" -P FORWARD DROP >"/dev/null" 2>&1
    iptables -w 10 -t "$table" -P PREROUTING DROP >"/dev/null" 2>&1
    iptables -w 10 -t "$table" -P POSROUTING DROP >"/dev/null" 2>&1

    #default policies ipv6
    ip6tables -w 10 -t "$table" -P OUTPUT DROP >"/dev/null" 2>&1
    ip6tables -w 10 -t "$table" -P INPUT DROP >"/dev/null" 2>&1
    ip6tables -w 10 -t "$table" -P FORWARD DROP >"/dev/null" 2>&1
    ip6tables -w 10 -t "$table" -P PREROUTING DROP >"/dev/null" 2>&1
    ip6tables -w 10 -t "$table" -P POSROUTING DROP >"/dev/null" 2>&1

    exit 0

done
CONTENT
}

##Default no permisssive rules
iptables_default_rules()
{
    write_rule << 'CONTENT'
#====== BASIC/NEEDED POLICIES ======
iptables -I INPUT 1 -i lo -j ACCEPT
iptables -I OUTPUT 1 -o lo -j ACCEPT

#====== ESTABLISHED-RELATED ======
iptables -I INPUT 2 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -I OUTPUT 2 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
CONTENT
}

##Firewall rules assistant
iptables_rule_wizzard()
{
    local table action chain target protocol port ip_source ip_dest interface_in interface_out dport sport target
    local modules=""
    local rule=""
    local local_option=-1

    echo ""
    printf "${FG_CYAN}=== Firewall Rules Assistant ===${NC}"
    echo ""

    #Select table
    read -r -p "Select Table (filter/nat/mangle/raw/security) [filter]: " table
    table="${table:-filter}"

    #Select action
    read -r -p "Select Action (A=add, I=insert, D=delete) [A]: " action
    action="${action:-A}"
    action="-${action^^}"

    #Select chain
    read -r -p "Select Chain (INPUT, OUTPUT, FORWARD, PREROUTING, POSTROUTING custom) [INPUT]: " chain
    chain="${chain:-INPUT}"

    #Select Protocol
    read -r -p "Select protocol (tcp/udp/icmp/Enter to skip): " procotol
    if [ -n "$protocol" ]; then
        protocol="-p protocol"
    else
        protocol=""
    fi

    #Ports (only if there is a protocol)
    if [ -n "$protocol" ]; then
        #Ask for a destination port/s
        read -r -p "¿Multi destination port? (y/n) [n]" local_option
        if check_yes_no_response "$local_option"; then
            read -r -p "Destination ports (ej: 80,443,8080): " dport

            modules="$modules -m multiport --dports $dport"
            dport=""
        else
            read -r -p "¿Destination port? (ENTER if not): " dport
            [[ -n "$dport" ]] && dport="--dport $dport"
        fi

        #Asks for a source port/s
        read -r -p "¿Multi source port? (y/n) [n]" local_option
        if check_yes_no_response "$local_option"; then
            read -r -p "Source ports (ej: 80,443,8080): " sport

            modules="$modules -m multiport --sports $sport"
            sport=""
        else
            read -r -p "¿Source port? (ENTER if not): " sport
            [[ -n "$sport" ]] && sport="--sport $sport"
        fi
    fi

    #IP source and destination
    read -r -p "¿Source IP/NET? (ENTER if not): " ip_source
    [[ -n "$ip_source" ]] && ip_source="-s $ip_source"

    read -r -p "¿Destination IP/NET? (ENTER if not): " ip_dest
    [[ -n "$ip_dest" ]] && ip_dest="-d $ip_dest"

    #Interface source and destination
    read -r -p "¿Source interface? (ENTER if not): " interface_in
    [[ -n "$interface_in" ]] && interface_in="-i $interface_in"

    read -r -p "¿Destination interface? (ENTER if not): " interface_out
    [[ -n "$interface_out" ]] && interface_out="-o $interface_out"

    #Extra modules
    local input_module=""
    read -r -p "¿Add extra check modules? (y/n) [n]: " local_option
    local_option="${local_option:-n}"
    while check_yes_no_response "$local_option"; do

        echo ""
        printf "1.-m conntrack --ctstate <states>\n
                2.-m state --state <estados>\n
                3.-m limit [options]\n
                4.-m recent [options]\n
                5.-m multiport [options]\n
                6.-m mac --mac-source <MAC>\n
                7.-m string [options]\n
                8.-m length --length <range>\n
                9.-m comment --comment <text>\n
                10.-m connlimit [options]\n
                11.-m owner [options]\n
                12.-m iprange [options]\n"
        
        read -r -p "Please enter the module sentence (only 1 per time): " input_module
        [[ -n "$input_module" ]] && modules="$modules $input_module"

        read -r -p "Add more modules? (y/n) [n]: " local_option
        local_option="${local_option:-n}"

    done

    #Select target
    local target_opts log_prefix log_level

    read -r -p "Select Target (ACCEPT, DROP, REJECT, DNAT, SNAT, MASQUERADE, LOG, RETURN) [DROP]: " target
    target="${target:-DROP}"
    target="-j ${target^^}"

    if [ "$target" == "REJECT" ]; then

        read -r -p "Reject message [icmp-port-unreachable]: " target_opts
        target_opts="${target_opts:-icmp-port-unreachable}"
        target_opts="--reject-with $target_opts"

    elif [ "$target" == "LOG" ]; then

        read -r -p "Log prefix [Firewall]: " log_prefix
        log_prefix="${log_prefix:-Firewall}"

        read -r -p "Log level (0-7) [4]: " log_level
        log_level="${log_level:-4}"

        target_opts="--log-prefix \"$log_prefix: \" --log-level $log_level"

    elif [ "$target" == "DNAT" ]; then

        read -r -p "¿DNAT destinaton? (ej: 192.168.0.4:80): " target_opts
        [[ -n "$target_opts" ]] && target_opts="--to-destination $target_opts"

    elif [ "$target" == "SNAT" ]; then

        read -r -p "¿SNAT destination? (ej: 201.33.7.67:1024-65000): " target_opts
        [[ -n "$target_opts" ]] && target_opts="--to-source $target_opts"

    fi

    #Rule Construction
    rule="iptables"
    [[ "$table" != "filter" ]] && rule="$rule -t $table"
    rule="$rule $action $chain"
    [[ -n "$protocol" ]] && rule="$rule $protocol"
    [[ -n "$dport" ]] && rule="$rule $dport"
    [[ -n "$sport" ]] && rule="$rule $sport"
    [[ -n "$ip_dest" ]] && rule="$rule $ip_dest"
    [[ -n "$ip_source" ]] && rule="$rule $ip_source"
    [[ -n "$interface_in" ]] && rule="$rule $interface_in"
    [[ -n "$interface_out" ]] && rule="$rule $interface_out"
    [[ -n "$modules" ]] && rule="$rule $modules"
    rule="$rule $target"
    [[ -n "$target_opts" ]] && rule="$rule $target_opts"

    rule=$(echo "$rule" | tr -s ' ')

    echo ""
    printf "${FG_BYELLOW}$rule${NC}\n"

    read -r -p "Is This rule correct? (y/n) [n]: " local_option
    local_option="${local_option:-n}"
    if check_yes_no_response "$local_option"; then
        printf_info "Writing the rule..." 2
        write_rule "$rule"
    else
        printf_warning "Deleting Rule..." 2
    fi
}