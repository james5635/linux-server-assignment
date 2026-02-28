#!/usr/bin/env bash
echo "fastestmirror=True" >> /etc/dnf/dnf.conf

dnf install -y haproxy

cat <<"EOF" >> /etc/haproxy/haproxy.cfg
frontend http_front
    bind *:80
    default_backend web_servers

backend web_servers
    balance roundrobin
    server web1 web1:80 check
    server web2 web2:80 check
EOF

exec haproxy -f /etc/haproxy/haproxy.cfg -db