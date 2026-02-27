#!/usr/bin/env bash

echo "fastestmirror=True" >> /etc/dnf/dnf.conf

# Add MongoDB repository
tee /etc/yum.repos.d/mongodb-org-7.0.repo > /dev/null <<EOF
[mongodb-org-7.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/9/mongodb-org/7.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://pgp.mongodb.com/server-7.0.asc
EOF

# Install MongoDB
dnf install -y mongodb-org

sed -i "s|bindIp: 127.0.0.1|bindIp: 0.0.0.0|" /etc/mongod.conf

exec mongod -f /etc/mongod.conf --fork
