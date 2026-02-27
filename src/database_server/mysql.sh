#!/usr/bin/env bash

echo "fastestmirror=True" >> /etc/dnf/dnf.conf

dnf install -y mariadb-server mariadb

/usr/bin/mariadb-install-db 
# sed -i "s|#bind-address=0.0.0.0|bind-address=0.0.0.0|" /etc/my.cnf.d/mariadb-server.cnf

/usr/bin/mariadbd-safe --nowatch

mariadb <<"EOF"
-- Source - https://stackoverflow.com/a/1559992
-- Posted by Yannick Motton, modified by community. See post 'Timeline' for change history
-- Retrieved 2026-02-26, License - CC BY-SA 4.0

CREATE USER 'monty'@'localhost' IDENTIFIED BY 'some_pass';
GRANT ALL PRIVILEGES ON *.* TO 'monty'@'localhost' WITH GRANT OPTION;
CREATE USER 'monty'@'%' IDENTIFIED BY 'some_pass';
GRANT ALL PRIVILEGES ON *.* TO 'monty'@'%' WITH GRANT OPTION;
EOF