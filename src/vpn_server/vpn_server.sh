#!/usr/bin/env bash
echo "fastestmirror=True" >> /etc/dnf/dnf.conf

dnf install epel-release -y

# Install OpenVPN and Easy-RSA
dnf install -y openvpn easy-rsa

# Setup Easy-RSA
mkdir -p /etc/openvpn/easy-rsa
cp -r /usr/share/easy-rsa/3/* /etc/openvpn/easy-rsa/
cd /etc/openvpn/easy-rsa

# Initialize PKI
./easyrsa init-pki
# Build CA
./easyrsa build-ca nopass <<< "OpenVPN-CA"
# Generate server request
./easyrsa gen-req server nopass <<< "server"
# Sign server certificate
./easyrsa sign-req server server <<< "yes"
# Generate DH parameters
./easyrsa gen-dh
# Generate TLS auth key
openvpn --genkey secret /etc/openvpn/ta.key

# Copy certificates
cp pki/ca.crt pki/private/server.key pki/issued/server.crt pki/dh.pem /etc/openvpn/

# Configure OpenVPN
tee /etc/openvpn/server.conf > /dev/null <<EOF
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

# Generate a client certificate
cd /etc/openvpn/easy-rsa 
./easyrsa gen-req client1 nopass <<< 'client1' 
./easyrsa sign-req client client1 <<< 'yes'

# Copy to clients
mkdir -p /etc/openvpn/clients
cp pki/private/client1.key pki/issued/client1.crt pki/ca.crt /etc/openvpn/ta.key /etc/openvpn/clients/

# Make client .ovpn
cd /etc/openvpn/clients/
cat > /etc/openvpn/clients/client1.ovpn <<EOF
client
dev tun
proto udp
remote YOUR_SERVER_IP 1194
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-CBC
tls-auth ta.key 1
verb 3
<ca>
$(cat ca.crt)
</ca>
<cert>
$(cat client1.crt)
</cert>
<key>
$(cat client1.key)
</key>
<tls-auth>
$(cat ta.key)
</tls-auth>
EOF

# Enable IP forwarding
# echo "net.ipv4.ip_forward = 1" | tee -a /etc/sysctl.conf
# sysctl -p

# Starting OpenVPN
exec openvpn --cd /etc/openvpn --config server.conf