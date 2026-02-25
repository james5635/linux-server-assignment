#!/usr/bin/env bash

echo "fastestmirror=True" >> /etc/dnf/dnf.conf

dnf install -y epel-release
dnf config-manager --set-enabled crb
dnf group install "Xfce" -y
dnf install -y tigervnc-server

mkdir -p ~/.vnc
cat << EOF > ~/.vnc/xstartup
#!/bin/sh

unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=XFCE
export XDG_SESSION_DESKTOP=XFCE

exec startxfce4 
EOF

chmod +x ~/.vnc/xstartup
echo -e "dog@123\ndog@123" | vncpasswd
exec vncserver -localhost no -geometry 1366x768 -fg