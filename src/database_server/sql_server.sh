#!/usr/bin/env bash
echo "fastestmirror=True" >> /etc/dnf/dnf.conf

curl -o /etc/yum.repos.d/mssql-server.repo https://packages.microsoft.com/config/rhel/9/mssql-server-2022.repo
dnf install -y mssql-server

# curl -o /etc/yum.repos.d/msprod.repo https://packages.microsoft.com/config/rhel/9/prod.repo
# dnf install -y mssql-tools18 unixODBC-devel

# Set environment variables to bypass interactive prompts if needed
export MSSQL_SA_PASSWORD='YourStrong!Password'
export ACCEPT_EULA='Y'

/opt/mssql/bin/mssql-conf setup <<< 1

/opt/mssql/bin/sqlservr > /dev/null 2>&1 &