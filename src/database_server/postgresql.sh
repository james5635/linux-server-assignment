#!/usr/bin/env bash

echo "fastestmirror=True" >> /etc/dnf/dnf.conf

dnf install -y postgresql-server postgresql-contrib

initdb -D /var/lib/pgsql/data
sed -i "s|#listen_addresses = 'localhost'|listen_addresses = '*'|" /var/lib/pgsql/data/postgresql.conf
sed -i "s|host    all             all             127.0.0.1/32            trust|host    all             all             0.0.0.0/0               trust|" /var/lib/pgsql/data/pg_hba.conf

exec postgres -D /var/lib/pgsql/data -c logging_collector=off