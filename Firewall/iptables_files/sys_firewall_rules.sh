#!/bin/bash
iptables -t nat -D FORWARD -m conntrack --ctstate ESTABLISHED -j DROP