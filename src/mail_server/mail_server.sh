#!/usr/bin/env bash
echo "fastestmirror=True" >> /etc/dnf/dnf.conf

dnf install -y postfix dovecot
dnf clean all


# Configure Postfix
tee /etc/postfix/main.cf > /dev/null <<EOF
myhostname = mail.example.com
mydomain = example.com
myorigin = \$mydomain
inet_interfaces = all
mydestination = \$myhostname, localhost.\$mydomain, localhost, \$mydomain
mynetworks = 0.0.0.0/0
home_mailbox = Maildir/
smtpd_banner = \$myhostname ESMTP
EOF

# Configure Dovecot
tee /etc/dovecot/conf.d/10-mail.conf > /dev/null <<EOF
mail_location = maildir:~/Maildir
EOF

useradd -m testuser && echo "testuser:password" | chpasswd
mkdir -p /home/testuser/Maildir/{cur,new,tmp}
chown -R testuser:testuser /home/testuser/Maildir

postfix start
exec dovecot -F
