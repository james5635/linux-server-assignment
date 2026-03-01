VPN Server
=================

Introduction
------------

Implementation
--------------

.. literalinclude:: ../../src/vpn_server/vpn_server.sh
   :language: bash

   
Usage
-----

.. code-block:: bash

    # Check OpenVPN tunnel is up inside the client container
    vpn-client ip addr show tun0
    
    # Check the client's routing table — default route should go through tun0
    vpn-client ip route
    
    # Check assigned VPN IP (should be in 10.8.0.x range)
    vpn-client ip addr show tun0 | grep inet