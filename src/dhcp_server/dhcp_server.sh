#!/usr/bin/env bash

# can use dhcpd/dnsmasq/udhcpd

echo "fastestmirror=True" >> /etc/dnf/dnf.conf

# Install DHCP server
dnf install -y dhcp-server iproute

# 1. Get the primary network interface
INTERFACE=$(ip route get 1.1.1.1 | awk '{print $5}')

# 2. Extract Network Information using 'ip'
ADDR_INFO=$(ip -4 addr show $INTERFACE | grep -oP 'inet \K[\d./]+')
CURRENT_IP=$(echo $ADDR_INFO | cut -d/ -f1)
CIDR=$(echo $ADDR_INFO | cut -d/ -f2)

# Broadcast Address
BROADCAST=$(ip -4 addr show $INTERFACE | awk '/brd / {print $4}')

# Network Address (e.g., 172.17.0.0)
NETWORK=$(ip route list dev $INTERFACE | awk '/proto kernel/ {print $1}' | cut -d/ -f1)

# Router (Your current Gateway)
ROUTER=$(ip route show default | awk '/default/ {print $3}')

# Helper: Convert CIDR prefix to Dotted Decimal Netmask
mask_conv() {
    local cidr=$1
    local mask=""
    for ((i=0; i<4; i++)); do
        local part=0
        if [ $cidr -ge 8 ]; then
            part=255
            cidr=$((cidr - 8))
        elif [ $cidr -gt 0 ]; then
            part=$((256 - 2**(8 - cidr)))
            cidr=0
        fi
        mask+="${part}"
        [ $i -lt 3 ] && mask+="."
    done
    echo $mask
}

NETMASK=$(mask_conv $CIDR)
PREFIX=$(echo $CURRENT_IP | cut -d. -f1-3)

# Configure DHCP
tee /etc/dhcp/dhcpd.conf > /dev/null <<EOF
# DHCP Server Configuration
option domain-name "example.com";
option domain-name-servers 8.8.8.8, 8.8.4.4;

default-lease-time 600;
max-lease-time 7200;
authoritative;

# subnet 192.168.1.0 netmask 255.255.255.0 {
#     range 192.168.1.100 192.168.1.200;
#     option routers 192.168.1.1;
#     option subnet-mask 255.255.255.0;
#     option broadcast-address 192.168.1.255;
# }

# subnet 172.17.0.0 netmask 255.255.0.0 {
#     range 172.17.0.100 172.17.0.200;
#     option routers 172.17.0.1;
#     option subnet-mask 255.255.0.0;
#     option broadcast-address 172.17.255.255;
# }

subnet $NETWORK netmask $NETMASK {
    range ${PREFIX}.100 ${PREFIX}.200;
    option routers $ROUTER;
    option subnet-mask $NETMASK;
    option broadcast-address $BROADCAST;
}
EOF

exec dhcpd -d