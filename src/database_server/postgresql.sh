#!/usr/bin/env bash

echo "fastestmirror=True" >> /etc/dnf/dnf.conf

dnf install -y postgresql-server postgresql-contrib

su -c "initdb -D /var/lib/pgsql/data" postgres
sed -i "s|#listen_addresses = 'localhost'|listen_addresses = '*'|" /var/lib/pgsql/data/postgresql.conf
sed -i "s|#unix_socket_directories = '/var/run/postgresql, /tmp'|unix_socket_directories = ''|" /var/lib/pgsql/data/postgresql.conf
sed -i "s|host    all             all             127.0.0.1/32            trust|host    all             all             0.0.0.0/0               trust|" /var/lib/pgsql/data/pg_hba.conf

exec su -c "postgres -D /var/lib/pgsql/data -c logging_collector=off" postgres