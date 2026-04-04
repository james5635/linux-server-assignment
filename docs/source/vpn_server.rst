VPN Server
=================

Introduction
------------

A VPN (Virtual Private Network) server acts as a secure, intermediate gateway between a user's device and the internet, establishing an encrypted "tunnel" for all data traffic. It is the cornerstone of privacy-focused browsing and secure remote access.

Implementation
--------------

Server
~~~~~~

.. literalinclude:: ../../src/vpn_server/vpn_server.sh
   :language: bash

Client
~~~~~~

.. literalinclude:: ../../src/vpn_server/vpn_client.sh
   :language: bash
   
Usage
-----

Connect to vpn server instance with ssh.

Before running this, make sure the vpn server have already finished stating the server.

.. code-block:: bash

    # run bash in the client
    docker exec -it linux-server-assignment-vpn_client-1 bash

    # Connect to the vpn server
    bash /root/vpn_client.sh

    # Check OpenVPN tunnel is up inside the client container
    ip addr show tun0
    
    # Check the client's routing table — default route should go through tun0
    ip route
    
    # Check assigned VPN IP (should be in 10.8.0.x range)
    ip addr show tun0 | grep inet

.. figure:: _static/vpn_server.png
