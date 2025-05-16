#!/bin/bash
PATH=$PATH:/run/current-system/sw/bin

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Change these parameters according to
# the proton0.conf file
vpndns="10.2.0.1"
vpnaddr="179.98.17.0/24"

# Change this through ip link
# This is iface to kill switch
iface="mv-enp4s0@if2"
# This is wireguard interface name
wgface="proton0"

# Other secret settings to change
# according to your needs
addrRange=192.168.0.0/24
anyWebuiPort=8000
sshPort=22
udpPorts="53,1300:1302,1194:1197,51820"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

iptables --flush
iptables -X

# Allow loopback and ping
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A OUTPUT -o "${wgface}" -j ACCEPT

# Allow to communicate the DCHP
iptables -A OUTPUT -d 255.255.255.255 -j ACCEPT
iptables -A INPUT -s 255.255.255.255 -j ACCEPT

# Allow LAN access for any WEBUI you need and SSH to manage
iptables -A INPUT -i "${iface}" -s $addrRange -d $addrRange -p tcp --dport $anyWebuiPort -j ACCEPT
iptables -A OUTPUT -o "${iface}" -s $addrRange -d $addrRange -p tcp --sport $anyWebuiPort -j ACCEPT
iptables -A INPUT -i "${iface}" -s $addrRange -d $addrRange -p tcp --dport $sshPort -j ACCEPT
iptables -A OUTPUT -o "${iface}" -s $addrRange -d $addrRange -p tcp --sport $sshPort -j ACCEPT

# Allow established sessions
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow VPN address and DNS
# Change ports according to your VPN provider
iptables -A OUTPUT -d "$vpndns" -j ACCEPT
iptables -A OUTPUT -d "$vpnaddr" -m multiport -p udp --dports "$udpPorts" -j ACCEPT

# Drop every IPV6
ip6tables -A INPUT -p all -j DROP
ip6tables -A FORWARD -p all -j DROP
ip6tables -A OUTPUT -p all -j DROP

# Drop everything frop "${iface}"
iptables -A INPUT -i "${iface}" -j DROP
iptables -A FORWARD -j DROP
iptables -A OUTPUT -o "${iface}" -j DROP

# Save the rules
iptables-save > /etc/iptables.rules
