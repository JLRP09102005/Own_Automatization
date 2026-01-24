#!/bin/bash

#====== VARIABLES ======
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
sudo iptables -P INPUT DROP
sudo iptables -P OUTPUT ACCEPT
sudo iptables -P FORWARD DROP

sudo ip6tables -P INPUT DROP
sudo ip6tables -P OUTPUT DROP
sudo ip6tables -P FORWARD DROP

sudo iptables -A INPUT -i lo -j ACCEPT #Grant local port access
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT #Allow full duplex connections and related relations from other connections
sudo iptables -A INPUT -m conntrack --ctstate INVALID -j DROP #Deny strange connections

#====== SSH ======
sudo iptables -t filter -A INPUT -i wlan0 -p tcp --dport 54321 -j ACCEPT