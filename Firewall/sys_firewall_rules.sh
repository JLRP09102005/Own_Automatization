#!/bin/bash
iptables -A INPUT -m conntrack -cstate NEW -j DROP