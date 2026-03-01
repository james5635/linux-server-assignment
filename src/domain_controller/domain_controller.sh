#!/usr/bin/env bash
echo "fastestmirror=True" >> /etc/dnf/dnf.conf

# docker run -h ipa.example.test --read-only --cgroupns=host -v /sys/fs/cgroup:/sys/fs/cgroup:rw  -ti \
#     -e PASSWORD=Secret123 \
#       freeipa/freeipa-server:centos-9-stream   ipa-server-install -U -r EXAMPLE.TEST --no-ntp --skip-mem-check

# manually installing freeipa
# dnf -y install freeipa-server freeipa-server-dns 
# ipa-server-install --setup-dns

# In domain_controller container
kinit admin
ipa user-add testuser --first=Test --last=User --password

# docker run  -it  --privileged --cgroupns=host --tmpfs=/run --tmpfs=/tmp --volume=/sys/fs/cgroup:/sys/fs/cgroup:rw trfore/docker-centos9-systemd:latest

# In centos9_systemd container
dnf -y install freeipa-client
echo "client1.example.test" > /etc/hostname
hostname client1.example.test
ipa-client-install --mkhomedir
id admin
getent passwd admin
id testuser
getent passwd testuser