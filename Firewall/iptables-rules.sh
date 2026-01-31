#!/bin/bash

tables=(filter)

#====== CLEAN ALL RULES ======
for table in "${tables[@]}"; do

    #clean all rules ipv4
    iptables -w 10 -t "$table" -F >"/dev/null" 2>&1
    iptables -w 10 -t "$table" -Z >"/dev/null" 2>&1
    iptables -w 10 -t "$table" -X >"/dev/null" 2>&1

    #clean all rules ipv6
    ip6tables -w 10 -t "$table" -F >"/dev/null" 2>&1
    ip6tables -w 10 -t "$table" -Z >"/dev/null" 2>&1
    ip6tables -w 10 -t "$table" -X >"/dev/null" 2>&1

done

#====== BASIC/NEEDED POLICIES ======
iptables -I INPUT 1 -i lo -j ACCEPT
iptables -I OUTPUT 1 -o lo -j ACCEPT

#====== ESTABLISHED-RELATED ======
iptables -I INPUT 2 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -I OUTPUT 2 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

#====== DHCP ======
iptables -A OUTPUT -p udp --dport 67:68 -o wlan0 -j ACCEPT
iptables -A INPUT -p udp --dport 67:68 -i wlan0 -j ACCEPT

#====== DNS ======
iptables -A OUTPUT -p tcp --dport 53 -o wlan0 -j ACCEPT
iptables -A INPUT -p tcp --sport 53 -i wlan0 -j ACCEPT

iptables -A OUTPUT -p udp --dport 53 -o wlan0 -j ACCEPT
iptables -A INPUT -p udp --sport 53 -i wlan0 -j ACCEPT

#====== NTP ======
iptables -A OUTPUT -p udp --dport 123 -o wlan0 -j ACCEPT

#====== ICMP ======
iptables -A INPUT -p icmp --icmp-type echo-reply -i wlan0 -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type echo-request -o wlan0 -j ACCEPT

#====== HTTP/S ======
iptables -A OUTPUT -p tcp --dport 80 -o wlan0 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -o wlan0 -j ACCEPT

#====== SSH ======
iptables -A INPUT -p tcp --dport 54321 -i wlan0 -j ACCEPT

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

done

exit 0