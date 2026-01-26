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
#Default rules
sudo iptables -P INPUT DROP
sudo iptables -P OUTPUT ACCEPT
sudo iptables -P FORWARD DROP

sudo ip6tables -P INPUT DROP
sudo ip6tables -P OUTPUT DROP
sudo ip6tables -P FORWARD DROP

sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
