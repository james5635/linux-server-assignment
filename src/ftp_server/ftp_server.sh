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

dnf install -y vsftpd
# dnf clean all

useradd -m ftpuser && echo "ftpuser:password" | chpasswd

vsftpd
sleep infinity