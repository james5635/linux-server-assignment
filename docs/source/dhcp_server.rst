DHCP Server
=================

Introduction
------------

A DHCP (Dynamic Host Configuration Protocol) Server is a network service that automatically assigns IP addresses and other critical network configuration parameters (such as subnet masks, default gateways, and DNS server addresses) to devices (clients) when they connect to a network.

Implementation
--------------

Server
~~~~~~

.. literalinclude:: ../../src/dhcp_server/dhcp_server.sh
   :language: bash

Client
~~~~~~

.. literalinclude:: ../../src/dhcp_client/dhcp_client.sh
   :language: bash
   
Usage
-----

.. code-block:: bash

    docker exec -it dhcp_client bash
    bash /root/dhcp_client.sh
    
    dhclient -d eth0
    
    # +-----------------+
    # | Sample Output:  |
    # +-----------------+
    # bash-5.1# dhclient -d eth0
    # Internet Systems Consortium DHCP Client 4.4.2b1
    # Copyright 2004-2019 Internet Systems Consortium.
    # All rights reserved.
    # For info, please visit https://www.isc.org/software/dhcp/
    # 
    # RTNETLINK answers: Operation not permitted
    # Listening on LPF/eth0/06:c4:ca:0d:c2:96
    # Sending on   LPF/eth0/06:c4:ca:0d:c2:96
    # Sending on   Socket/fallback
    # DHCPREQUEST for 172.17.0.100 on eth0 to 255.255.255.255 port 67 (xid=0x89771024)
    # DHCPACK of 172.17.0.100 from 172.17.0.2 (xid=0x89771024)
    # RTNETLINK answers: Operation not permitted
    # RTNETLINK answers: Operation not permitted
    # System has not been booted with systemd as init system (PID 1). Can't operate.
    # Failed to connect to bus: Host is down
    # bound to 172.17.0.100 -- renewal in 270 seconds.
