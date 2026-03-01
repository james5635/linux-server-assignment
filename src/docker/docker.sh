#!/usr/bin/env bash
echo "fastestmirror=True" >> /etc/dnf/dnf.conf

dnf -y install dnf-plugins-core
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# curl -L https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl3.py -o /usr/bin/systemctl && chmod +x /usr/bin/systemctl

cat <<"EOF" > /etc/docker/daemon.json
{
  "storage-driver": "vfs"
}
EOF

# systemctl start docker
dockerd &

# install sshd for remote ssh
dnf install -y openssh-server
sed -i "s|#PermitRootLogin prohibit-password|PermitRootLogin yes|" /etc/ssh/sshd_config
echo "root:password" | chpasswd
ssh-keygen -A
/usr/sbin/sshd

sleep infinity