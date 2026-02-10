#!/bin/bash

#====== SERVICE FUNCTIONS ======
##Service Writer
# shellcheck disable=SC2120
write_service()
{
    if [ "$#" -gt 0 ]; then
        printf "$@" >> "$SERVICE_FILE"
    else
        cat >> "$SERVICE_FILE"
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
    local 
}