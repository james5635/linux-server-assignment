#!/usr/bin/env bash
echo "fastestmirror=True" >> /etc/dnf/dnf.conf

# can use systemctl alternative for container 
# curl -L https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl3.py -o /usr/bin/systemctl && chmod +x /usr/bin/systemctl

dnf install -y cronie openssh-clients

mkdir /backup

cat <<"EOF" >> /etc/crontab
*  *  *  *  * root scp -r root@ftp_server:/home/ftpuser /backup 2>&1 >> /log.txt
EOF

mkdir -p /root/.ssh
cat <<"EOF" > /root/.ssh/id_ed25519
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACBcNrGfQQTSuDIlL1jyThNUqQpfzDGxyq/jcK1UDp/SpwAAAJgLVinuC1Yp
7gAAAAtzc2gtZWQyNTUxOQAAACBcNrGfQQTSuDIlL1jyThNUqQpfzDGxyq/jcK1UDp/Spw
AAAEAC2bPdiHQtIbmXXYgGqQGhue7YITu6ANtAUD0Ygdacilw2sZ9BBNK4MiUvWPJOE1Sp
Cl/MMbHKr+NwrVQOn9KnAAAAEXJvb3RAYWRjYTc4NTE0ZWRjAQIDBA==
-----END OPENSSH PRIVATE KEY-----
EOF
chmod 600 /root/.ssh/id_ed25519
ssh-keyscan ftp_server >> /root/.ssh/known_hosts

exec crond -n