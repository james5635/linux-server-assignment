#!/usr/bin/env bash
set -e

echo "fastestmirror=True" >> /etc/dnf/dnf.conf
dnf install -y postfix dovecot cyrus-sasl cyrus-sasl-plain cyrus-sasl-lib
dnf clean all

# Dovecot
sed -i "s|ssl = required|ssl = no|"                                           /etc/dovecot/conf.d/10-ssl.conf
sed -i "s|ssl_cert = </etc/pki/dovecot/certs/dovecot.pem|ssl_cert = |"       /etc/dovecot/conf.d/10-ssl.conf
sed -i "s|ssl_key = </etc/pki/dovecot/private/dovecot.pem|ssl_key = |"       /etc/dovecot/conf.d/10-ssl.conf
sed -i "s|#disable_plaintext_auth = yes|disable_plaintext_auth = no|"         /etc/dovecot/conf.d/10-auth.conf
sed -i "s|auth_mechanisms = plain|auth_mechanisms = plain login|"              /etc/dovecot/conf.d/10-auth.conf

# Expose Dovecot SASL socket for Postfix
cat >> /etc/dovecot/conf.d/10-master.conf << 'EOF'

service auth {
  unix_listener /var/spool/postfix/private/auth {
    mode = 0660
    user = postfix
    group = postfix
  }
}
EOF

# Postfix
postconf -e "myhostname = mail.mail.local"
postconf -e "mydomain = mail.local"
postconf -e "myorigin = \$mydomain"

postconf -e "home_mailbox = Maildir/"
postconf -e "inet_interfaces = all"
postconf -e "inet_protocols = ipv4"

postconf -e "mydestination = \$myhostname, localhost.\$mydomain, localhost, \$mydomain"
postconf -e "mynetworks = 127.0.0.0/8"

# SASL auth via Dovecot socket
postconf -e "smtpd_sasl_type = dovecot"
postconf -e "smtpd_sasl_path = private/auth"
postconf -e "smtpd_sasl_auth_enable = yes"
postconf -e "smtpd_sasl_security_options = noanonymous"
postconf -e "smtpd_sasl_local_domain = \$mydomain"
postconf -e "broken_sasl_auth_clients = yes"

# Allow authenticated users to send
postconf -e "smtpd_relay_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination"
postconf -e "smtpd_recipient_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination"

newaliases

# Users
for user in testuser student; do
  id "$user" &>/dev/null || useradd -m "$user"
  echo "$user:password" | chpasswd
  mkdir -p /home/$user/Maildir/{cur,new,tmp}
  chown -R $user:$user /home/$user/Maildir
done

# Start
dovecot
postfix start

sleep infinity