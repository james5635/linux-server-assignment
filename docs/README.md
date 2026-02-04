# CentOS Stream 9 Server Implementation Guide

I'll provide you with a comprehensive guide to implement all 15 services on CentOS Stream 9. This is a substantial deployment, so I'll organize it systematically.

## Prerequisites

```bash
# Update system
sudo dnf update -y

# Install EPEL repository
sudo dnf install -y epel-release

# Install common tools
sudo dnf install -y vim wget curl net-tools firewalld
```

## 1. File Server (Samba)

```bash
# Install Samba
sudo dnf install -y samba samba-common samba-client

# Create shared directory
sudo mkdir -p /srv/samba/shared
sudo chmod 2775 /srv/samba/shared

sudo setsebool -P samba_export_all_rw on
sudo semanage fcontext -a -t samba_share_t "/srv/samba/shared(/.*)?"
sudo restorecon -Rv /srv/samba/shared

# Backup original config
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak

# Edit Samba configuration
sudo tee /etc/samba/smb.conf > /dev/null <<EOF
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

# Enable and start services
sudo systemctl enable --now smb nmb
sudo firewall-cmd --permanent --add-service=samba
sudo firewall-cmd --reload

# Create Samba user (optional)
sudo useradd sambauser
sudo smbpasswd -a sambauser
```

## 2. Proxy Server (Squid)

```bash
# Install Squid
sudo dnf install -y squid

# Backup configuration
sudo cp /etc/squid/squid.conf /etc/squid/squid.conf.bak

# Configure Squid
sudo tee /etc/squid/squid.conf > /dev/null <<EOF
# ACL definitions
acl localnet src 192.168.0.0/16
acl localnet src 10.0.0.0/8
acl SSL_ports port 443
acl Safe_ports port 80
acl Safe_ports port 443
acl Safe_ports port 21
acl CONNECT method CONNECT

# Deny requests to unknown ports
http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports

# Allow localhost and localnet
http_access allow localhost
http_access allow localnet

# Deny all other access
http_access deny all

# Squid listening port
http_port 3128

# Cache settings
cache_dir ufs /var/spool/squid 10000 16 256
cache_mem 256 MB
maximum_object_size 50 MB
minimum_object_size 0 KB

# Leave coredumps in the first cache dir
coredump_dir /var/spool/squid

# Refresh patterns
refresh_pattern ^ftp:           1440    20%     10080
refresh_pattern ^gopher:        1440    0%      1440
refresh_pattern -i (/cgi-bin/|\?) 0     0%      0
refresh_pattern .               0       20%     4320
EOF

# Initialize cache and start
sudo squid -z
sudo systemctl enable --now squid
sudo firewall-cmd --permanent --add-port=3128/tcp
sudo firewall-cmd --reload
```

## 3. DNS Server (BIND)

```bash
# Install BIND
sudo dnf install -y bind bind-utils

# Backup configuration
sudo cp /etc/named.conf /etc/named.conf.bak

# Configure BIND
sudo tee /etc/named.conf > /dev/null <<EOF
options {
    listen-on port 53 { 127.0.0.1; any; };
    listen-on-v6 port 53 { ::1; };
    directory "/var/named";
    dump-file "/var/named/data/cache_dump.db";
    statistics-file "/var/named/data/named_stats.txt";
    memstatistics-file "/var/named/data/named_mem_stats.txt";
    allow-query { localhost; 192.168.0.0/16; 10.0.0.0/8; };
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

zone "." IN {
    type hint;
    file "named.ca";
};

include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";
EOF

# Enable and start
sudo systemctl enable --now named
sudo firewall-cmd --permanent --add-service=dns
sudo firewall-cmd --reload
```

## 4. DHCP Server

```bash
# Install DHCP server
sudo dnf install -y dhcp-server

# Configure DHCP
sudo tee /etc/dhcp/dhcpd.conf > /dev/null <<EOF
# DHCP Server Configuration
option domain-name "example.com";
option domain-name-servers 8.8.8.8, 8.8.4.4;

default-lease-time 600;
max-lease-time 7200;
authoritative;

subnet 192.168.1.0 netmask 255.255.255.0 {
    range 192.168.1.100 192.168.1.200;
    option routers 192.168.1.1;
    option subnet-mask 255.255.255.0;
    option broadcast-address 192.168.1.255;
}
EOF

# Enable and start
sudo systemctl enable --now dhcpd
sudo firewall-cmd --permanent --add-service=dhcp
sudo firewall-cmd --reload
```

## 5. VPN Server (OpenVPN)

```bash
# Install OpenVPN and Easy-RSA
sudo dnf install -y openvpn easy-rsa

# Setup Easy-RSA
sudo mkdir -p /etc/openvpn/easy-rsa
sudo cp -r /usr/share/easy-rsa/3/* /etc/openvpn/easy-rsa/
cd /etc/openvpn/easy-rsa

# Initialize PKI
sudo ./easyrsa init-pki
sudo ./easyrsa build-ca nopass
sudo ./easyrsa gen-req server nopass
sudo ./easyrsa sign-req server server
sudo ./easyrsa gen-dh
sudo openvpn --genkey secret /etc/openvpn/ta.key

# Copy certificates
sudo cp pki/ca.crt pki/private/server.key pki/issued/server.crt pki/dh.pem /etc/openvpn/

# Configure OpenVPN
sudo tee /etc/openvpn/server.conf > /dev/null <<EOF
port 1194
proto udp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh.pem
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
keepalive 10 120
tls-auth ta.key 0
cipher AES-256-CBC
user nobody
group nobody
persist-key
persist-tun
status openvpn-status.log
verb 3
EOF

# Enable IP forwarding
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Firewall rules
sudo firewall-cmd --permanent --add-service=openvpn
sudo firewall-cmd --permanent --add-masquerade
sudo firewall-cmd --reload

# Enable and start
sudo systemctl enable --now openvpn-server@server
```

## 6. Terminal Server (VNC for Thin Clients)

```bash
# Install VNC server and desktop environment
sudo dnf groupinstall -y "Server with GUI"
sudo dnf install -y tigervnc-server

# Configure VNC for user
sudo cp /lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@:1.service

# Edit the service file (replace USER with actual username)
sudo sed -i 's/<USER>/yourusername/g' /etc/systemd/system/vncserver@:1.service

# Set VNC password
vncpasswd

# Enable and start
sudo systemctl daemon-reload
sudo systemctl enable --now vncserver@:1
sudo firewall-cmd --permanent --add-port=5901/tcp
sudo firewall-cmd --reload
```

## 7. Web Server (Apache)

```bash
# Install Apache
sudo dnf install -y httpd mod_ssl

# Create test page
sudo tee /var/www/html/index.html > /dev/null <<EOF
<!DOCTYPE html>
<html>
<head><title>CentOS Web Server</title></head>
<body>
<h1>Welcome to CentOS Stream 9 Web Server</h1>
<p>Server is running successfully!</p>
</body>
</html>
EOF

# Enable and start
sudo systemctl enable --now httpd
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```

## 8. Mail Server (Postfix + Dovecot)

```bash
# Install mail services
sudo dnf install -y postfix dovecot

# Configure Postfix
sudo tee /etc/postfix/main.cf > /dev/null <<EOF
myhostname = mail.example.com
mydomain = example.com
myorigin = \$mydomain
inet_interfaces = all
mydestination = \$myhostname, localhost.\$mydomain, localhost, \$mydomain
mynetworks = 127.0.0.0/8, 192.168.0.0/16
home_mailbox = Maildir/
smtpd_banner = \$myhostname ESMTP
EOF

# Configure Dovecot
sudo tee /etc/dovecot/conf.d/10-mail.conf > /dev/null <<EOF
mail_location = maildir:~/Maildir
EOF

# Enable and start
sudo systemctl enable --now postfix dovecot
sudo firewall-cmd --permanent --add-service=smtp
sudo firewall-cmd --permanent --add-service=imap
sudo firewall-cmd --permanent --add-service=pop3
sudo firewall-cmd --reload
```

## 9. Database Servers

### PostgreSQL
```bash
# Install PostgreSQL
sudo dnf install -y postgresql-server postgresql-contrib

# Initialize database
sudo postgresql-setup --initdb

# Enable and start
sudo systemctl enable --now postgresql

# Configure for network access (optional)
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /var/lib/pgsql/data/postgresql.conf
echo "host all all 0.0.0.0/0 md5" | sudo tee -a /var/lib/pgsql/data/pg_hba.conf
sudo systemctl restart postgresql

# Firewall
sudo firewall-cmd --permanent --add-port=5432/tcp
sudo firewall-cmd --reload
```

### MongoDB
```bash
# Add MongoDB repository
sudo tee /etc/yum.repos.d/mongodb-org-7.0.repo > /dev/null <<EOF
[mongodb-org-7.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/9/mongodb-org/7.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://pgp.mongodb.com/server-7.0.asc
EOF

# Install MongoDB
sudo dnf install -y mongodb-org

# Enable and start
sudo systemctl enable --now mongod

# Firewall
sudo firewall-cmd --permanent --add-port=27017/tcp
sudo firewall-cmd --reload
```

### MySQL/MariaDB
```bash
# Install MariaDB
sudo dnf install -y mariadb-server mariadb

# Enable and start
sudo systemctl enable --now mariadb

# Secure installation
sudo mysql_secure_installation

# Firewall
sudo firewall-cmd --permanent --add-port=3306/tcp
sudo firewall-cmd --reload
```

## 10. Backup Server (Rsync + Bacula)

```bash
# Install backup tools
sudo dnf install -y rsync bacula-director bacula-storage bacula-client bacula-console

# Create backup directory
sudo mkdir -p /backup

# Simple rsync backup script
sudo tee /usr/local/bin/backup.sh > /dev/null <<'EOF'
#!/bin/bash
BACKUP_DIR="/backup"
SOURCE_DIRS="/etc /home /var/www"
DATE=$(date +%Y%m%d)

for dir in $SOURCE_DIRS; do
    rsync -avz --delete $dir $BACKUP_DIR/$DATE/
done
EOF

sudo chmod +x /usr/local/bin/backup.sh

# Create cron job for daily backups
echo "0 2 * * * root /usr/local/bin/backup.sh" | sudo tee -a /etc/crontab
```

## 11. Load Balancing (HAProxy)

```bash
# Install HAProxy
sudo dnf install -y haproxy

# Configure HAProxy
sudo tee /etc/haproxy/haproxy.cfg > /dev/null <<EOF
global
    log /dev/log local0
    log /dev/log local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin
    stats timeout 30s
    user haproxy
    group haproxy
    daemon

defaults
    log global
    mode http
    option httplog
    option dontlognull
    timeout connect 5000
    timeout client 50000
    timeout server 50000

frontend http_front
    bind *:80
    stats uri /haproxy?stats
    default_backend http_back

backend http_back
    balance roundrobin
    server web1 192.168.1.10:80 check
    server web2 192.168.1.11:80 check
EOF

# Enable and start
sudo systemctl enable --now haproxy
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload
```

## 12. Failover Cluster (Pacemaker + Corosync)

```bash
# Install cluster packages
sudo dnf install -y pcs pacemaker corosync fence-agents-all

# Enable and start pcsd
sudo systemctl enable --now pcsd

# Set password for hacluster user
echo "hacluster:password" | sudo chpasswd

# Firewall rules
sudo firewall-cmd --permanent --add-service=high-availability
sudo firewall-cmd --reload

# On all cluster nodes, authenticate (run on one node)
# sudo pcs host auth node1 node2 -u hacluster -p password

# Create cluster (run on one node)
# sudo pcs cluster setup mycluster node1 node2
# sudo pcs cluster start --all
# sudo pcs cluster enable --all
```

## 13. FTP Server (vsftpd)

```bash
# Install vsftpd
sudo dnf install -y vsftpd

# Configure vsftpd
sudo tee /etc/vsftpd/vsftpd.conf > /dev/null <<EOF
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
xferlog_enable=YES
connect_from_port_20=YES
xferlog_std_format=YES
listen=YES
pam_service_name=vsftpd
userlist_enable=YES
tcp_wrappers=YES
chroot_local_user=YES
allow_writeable_chroot=YES
pasv_enable=YES
pasv_min_port=30000
pasv_max_port=31000
EOF

# Enable and start
sudo systemctl enable --now vsftpd

# Firewall
sudo firewall-cmd --permanent --add-service=ftp
sudo firewall-cmd --permanent --add-port=30000-31000/tcp
sudo firewall-cmd --reload
```

## 14. Container (Docker)

```bash
# Install Docker
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Enable and start
sudo systemctl enable --now docker

# Add user to docker group
sudo usermod -aG docker $USER

# Test Docker
sudo docker run hello-world

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

## 15. Domain Controller (FreeIPA)

```bash
# Install FreeIPA server
sudo dnf install -y freeipa-server freeipa-server-dns

# Setup FreeIPA (interactive)
sudo ipa-server-install \
    --realm EXAMPLE.COM \
    --domain example.com \
    --ds-password DSPassword123 \
    --admin-password AdminPassword123 \
    --hostname dc.example.com \
    --setup-dns \
    --forwarder=8.8.8.8 \
    --forwarder=8.8.4.4 \
    --no-ntp

# Firewall rules
sudo firewall-cmd --permanent --add-service={freeipa-ldap,freeipa-ldaps,dns,ntp}
sudo firewall-cmd --permanent --add-port={80/tcp,443/tcp,389/tcp,636/tcp,88/tcp,88/udp,464/tcp,464/udp,53/tcp,53/udp,123/udp}
sudo firewall-cmd --reload

# Obtain Kerberos ticket
kinit admin
```

## Verification Commands

```bash
# File Server
smbclient -L localhost

# Proxy
curl -x http://localhost:3128 http://www.google.com

# DNS
dig @localhost google.com

# Web Server
curl http://localhost

# Docker
docker ps

# PostgreSQL
sudo -u postgres psql -c "SELECT version();"

# FreeIPA
ipa user-find admin
```

## Important Notes

1. **Security**: Change all default passwords and configure proper authentication
2. **Network**: Adjust IP addresses and subnets to match your network
3. **SELinux**: May need configuration for some services: `sudo setsebool -P httpd_can_network_connect 1`
4. **Firewall**: Review and adjust firewall rules based on your security requirements
5. **Resources**: This is a comprehensive setup - consider using separate servers for production
6. **Testing**: Test each service individually before deploying to production
7. **Monitoring**: Consider installing monitoring tools like Nagios or Zabbix
8. **Documentation**: Keep detailed records of configurations and passwords

Would you like me to provide more detailed configuration for any specific service, or help you with troubleshooting any particular component?