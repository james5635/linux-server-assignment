#!/usr/bin/env bash
echo "fastestmirror=True" >> /etc/dnf/dnf.conf

# installing freeipa with docker
# docker run -h ipa.example.test --read-only --cgroupns=host -v /sys/fs/cgroup:/sys/fs/cgroup:rw  -ti \
#     -e PASSWORD=Secret123 \
#       freeipa/freeipa-server:centos-9-stream   ipa-server-install -U -r EXAMPLE.TEST --no-ntp --skip-mem-check

# manually installing freeipa
# dnf -y install freeipa-server freeipa-server-dns 
# ipa-server-install --setup-dns

ipa-server-install -U -r EXAMPLE.TEST --no-ntp --skip-mem-check

# for client
# docker run  -it  --privileged --cgroupns=host --tmpfs=/run --tmpfs=/tmp --volume=/sys/fs/cgroup:/sys/fs/cgroup:rw trfore/docker-centos9-systemd:latest
