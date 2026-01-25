#!/bin/bash
#Clean All Firewall Rules
tables=(filter nat mangle raw security)
for table in "${tables[@]}"; do
    sudo iptables -t "$table" -F
    sudo iptables -t "$table" -X
    sudo iptables -t "$table" -Z

    sudo ip6tables -t "$table" -F
    sudo ip6tables -t "$table" -X
    sudo ip6tables -t "$table" -Z
done
