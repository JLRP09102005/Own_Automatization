#!/bin/bash

tables=(filter nat mangle raw security)

#====== Clean Rules ======
for table in "${tables[@]}"; do
    sudo iptables -t "$table" -F
    sudo iptables -t "$table" -X
    sudo iptables -t "$table" -Z

    sudo ip6tables -t "$table" -F
    sudo ip6tables -t "$table" -X
    sudo ip6tables -t "$table" -Z
done

#====== Default Rules ======
sudo iptables -P INPUT -j DROP
sudo iptables -P OUTPUT -j ACCEPT
sudo iptables -P FORWARD -j DROP

sudo ip6tables -P INPUT -j DROP
sudo ip6tables -P OUTPUT -j DROP
sudo ip6tables -P FORWARD -j DROP

sudo iptables -A INPUT -i lo -j ACCEPT #Grant local port access
sudo iptables -A INPUT -m conntrack ESTABLISHED, RELATED -j ACCEPT #Allow full duplex connections and related relations from other connections
sudo iptables -A INPUT -m conntrack INVALID -j DROP #Deny strange connections

#====== SSH ======
sudo iptables -A INPUT -p 54321 -i "wlan0" -j ACCEPT