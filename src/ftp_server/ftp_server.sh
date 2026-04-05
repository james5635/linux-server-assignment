#!/usr/bin/env bash
echo "fastestmirror=True" >> /etc/dnf/dnf.conf

# install sshd for backup
dnf install -y openssh-server
mkdir -p /root/.ssh
cat <<"EOF" > /root/.ssh/authorized_keys
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFw2sZ9BBNK4MiUvWPJOE1SpCl/MMbHKr+NwrVQOn9Kn root@adca78514edc
EOF
chmod 600 /root/.ssh/authorized_keys
ssh-keygen -A
/usr/sbin/sshd


dnf install -y --allowerasing vsftpd curl
dnf clean all

PUBLIC_IP=$(curl http://checkip.amazonaws.com)
useradd -m ftpuser && echo "ftpuser:password" | chpasswd

# Configure vsftpd for Passive Mode
echo "pasv_enable=YES" >> /etc/vsftpd/vsftpd.conf
echo "pasv_min_port=21100" >> /etc/vsftpd/vsftpd.conf
echo "pasv_max_port=21110" >> /etc/vsftpd/vsftpd.conf
echo "pasv_address=${PUBLIC_IP}" >> /etc/vsftpd/vsftpd.conf

vsftpd
sleep infinity