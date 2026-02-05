#!/usr/bin/env bash
echo "fastestmirror=True" >> /etc/dnf/dnf.conf

dnf install -y samba samba-common samba-client

mkdir -p /srv/samba/shared
chmod 777 /srv/samba/shared

tee /etc/samba/smb.conf > /dev/null <<EOF
[global]
workgroup = WORKGROUP
server string = CentOS File Server
netbios name = centos-fs
security = user
map to guest = bad user
dns proxy = no

[shared]
path = /srv/samba/shared
browseable = yes
writable = yes
guest ok = yes
read only = no
force create mode = 0775
force directory mode = 0775
EOF

# background/daemon => run in other process
# foreground/interactive => run in the main process
exec smbd --foreground --no-process-group