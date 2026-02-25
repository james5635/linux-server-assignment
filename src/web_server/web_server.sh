#!/usr/bin/env bash

echo "fastestmirror=True" >> /etc/dnf/dnf.conf

dnf install -y httpd

# # Create test page
# sudo tee /var/www/html/index.html > /dev/null <<EOF
# <!DOCTYPE html>
# <html>
# <head><title>CentOS Web Server</title></head>
# <body>
# <h1>Welcome to CentOS Stream 9 Web Server</h1>
# <p>Server is running successfully!</p>
# </body>
# </html>
# EOF

exec httpd -DFOREGROUND