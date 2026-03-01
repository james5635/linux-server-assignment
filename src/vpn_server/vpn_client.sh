#!/usr/bin/env bash
echo "fastestmirror=True" >> /etc/dnf/dnf.conf

dnf install epel-release -y

# Install OpenVPN and Easy-RSA
dnf install -y openvpn easy-rsa

exec openvpn --config /etc/openvpn/clients/client1.ovpn