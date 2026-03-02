#!/usr/bin/env bash
echo "fastestmirror=True" >> /etc/dnf/dnf.conf

# Install DHCP client
dnf install -y dhcp-client
