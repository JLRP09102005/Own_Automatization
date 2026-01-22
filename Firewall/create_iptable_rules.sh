#!/bin/bash

tables=(filter nat mangle raw security)

#====== Clean Rules ======
for table in ${tables[@]}; do
    sudo iptables -t $table -F
    sudo iptables -t $table -X
    sudo iptables -t $table -Z

    sudo ip6tables -t $table -F
    sudo ip6tables -t $table -X
    sudo ip6tables -t $table -Z
done

#====== Default Rules ======
iptables -P INPUT -j DROP
iptables -P OUTPUT -j ACCEPT
iptables -P FORWARD -j DROP

ip6tables -P INPUT -j DROP
ip6tables -P OUTPUT -j DROP
ip6tables -P FORWARD -j DROP

iptables -A -i lo -j ACCEPT #Grant local port access
iptables -A INPUT -m conntrack --cstate ESTABLISHED,RELATED -j ACCEPT

#====== SSH ======
