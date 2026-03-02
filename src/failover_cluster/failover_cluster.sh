#!/usr/bin/env bash

# +------------------+
# | Run on each node |
# +------------------+

echo "fastestmirror=True" >> /etc/dnf/dnf.conf

dnf config-manager --set-enabled highavailability
dnf install -y pcs pacemaker corosync fence-agents-all iproute
dnf install -y nginx

echo "hacluster:password" | chpasswd
# passwd hacluster
systemctl start pcsd
