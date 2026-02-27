#!/usr/bin/env bash
echo "fastestmirror=True" >> /etc/dnf/dnf.conf

dnf install -y postfix dovecot
dnf clean all

sed -i "s|ssl = required|ssl = no|" /etc/dovecot/conf.d/10-ssl.conf
sed -i "s|ssl_cert = </etc/pki/dovecot/certs/dovecot.pem|ssl_cert = |" /etc/dovecot/conf.d/10-ssl.conf
sed -i "s|ssl_key = </etc/pki/dovecot/private/dovecot.pem|ssl_key = |" /etc/dovecot/conf.d/10-ssl.conf

sed -i "s|#disable_plaintext_auth = yes|disable_plaintext_auth = no|" /etc/dovecot/conf.d/10-auth.conf
sed -i "s|auth_mechanisms = plain|auth_mechanisms = plain login|" /etc/dovecot/conf.d/10-auth.conf

useradd -m testuser && echo "testuser:password" | chpasswd
mkdir -p /home/testuser/Maildir/{cur,new,tmp}
chown -R testuser:testuser /home/testuser/Maildir

useradd -m student && echo "student:password" | chpasswd
mkdir -p /home/student/Maildir/{cur,new,tmp}
chown -R student:student /home/student/Maildir

postconf -e "home_mailbox = Maildir/"
postconf -e "inet_interfaces = all"
newaliases

postfix start

exec dovecot -F

# echo "Test mail" | sendmail testuser@localhost
# ls /home/testuser/Maildir/new