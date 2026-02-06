#!/usr/bin/env bash
echo "fastestmirror=True" >> /etc/dnf/dnf.conf

dnf install -y bind bind-utils

mkdir -p /run/named /var/named/dynamic
chown -R named:named /run/named /var/named
chmod 777 /run/named /var/named

# Configure BIND
tee /etc/named.conf > /dev/null <<EOF
options {
    listen-on port 53 { any; };
    listen-on-v6 port 53 { ::1; };
    directory "/var/named";
    dump-file "/var/named/data/cache_dump.db";
    statistics-file "/var/named/data/named_stats.txt";
    memstatistics-file "/var/named/data/named_mem_stats.txt";
    # allow-query { localhost; 192.168.0.0/16; 10.0.0.0/8; };
    allow-query { any; };
    recursion yes;
    dnssec-validation yes;
    managed-keys-directory "/var/named/dynamic";
    pid-file "/run/named/named.pid";
    session-keyfile "/run/named/session.key";
};

logging {
    channel default_debug {
        file "data/named.run";
        severity dynamic;
    };
};

zone "example.internal" IN {
    type master;
    file "example.internal.dns";
};

zone "devspeed.com" IN {
    type master;
    file "devspeed.com.dns";
};

zone "." IN {
    type hint;
    file "named.ca";
};

include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";
EOF

tee /var/named/example.internal.dns > /dev/null <<"EOF"
$TTL 86400
@   IN  SOA ns1.example.internal. admin.example.internal. (
        2026020601 ; Serial
        3600       ; Refresh
        1800       ; Retry
        604800     ; Expire
        86400 )    ; Minimum

; Name servers
@       IN  NS  ns1.example.internal.

; A records
ns1     IN  A   10.0.1.10
server1 IN  A   10.0.1.10
EOF

tee /var/named/devspeed.com.dns > /dev/null <<"EOF"
$TTL 86400
@   IN  SOA ns1.devspeed.com. admin.devspeed.com. (
        2026020601
        3600
        1800
        604800
        86400 )

; Name servers
@       IN  NS  ns1.devspeed.com.

; A records
ns1     IN  A   192.168.1.1
console IN  A   192.168.1.11
go      IN  A   192.168.1.29
blog    IN  A   192.168.1.30
shop    IN  A   192.168.1.31
support IN  A   192.168.1.32
mail    IN  A   192.168.1.33
www     IN  A   192.168.1.34
www2    IN  A   192.168.1.100
EOF

exec named -g -u named