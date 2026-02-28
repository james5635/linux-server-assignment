#!/usr/bin/env bash
echo "fastestmirror=True" >> /etc/dnf/dnf.conf

dnf install -y vsftpd
# dnf clean all

useradd -m ftpuser && echo "ftpuser:password" | chpasswd

vsftpd
sleep infinity