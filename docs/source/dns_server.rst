DNS Server
=============

Introduction
------------

BIND is the most widely used software for implementing a Domain Name System (DNS) server, which translates human-readable domain names into IP addresses that computers use to locate each other on a network. BIND allows administrators to configure authoritative DNS zones, manage domain records, and handle recursive queries, enabling reliable name resolution for both internal networks and the internet. A DNS server, in general, is essential for directing network traffic efficiently, supporting web browsing, email delivery, and other services that rely on domain names.

Implementation
--------------

.. literalinclude:: ../../src/dns_server/dns_server.sh
   :language: bash


Usage
-----

.. code-block:: bash
    
    dog  console.devspeed.com @127.0.0.1
    dog  go.devspeed.com @127.0.0.1
    dog  blog.devspeed.com @127.0.0.1
    dog  shop.devspeed.com @127.0.0.1
    dog  support.devspeed.com @127.0.0.1
    dog  mail.devspeed.com @127.0.0.1
    dog  www.devspeed.com @127.0.0.1
    dog  www2.devspeed.com @127.0.0.1
    
    # +---------------+
    # | Sample Output |
    # +---------------+
    # [ 11:17AM ]  [ jame@Jame-Linux:~/Desktop/coding/linux-server-assignment/src(master✗) ]
    # $ dog  console.devspeed.com @127.0.0.1
    # A console.devspeed.com. 1d0h00m00s   192.168.1.11
    # [ 11:18AM ]  [ jame@Jame-Linux:~/Desktop/coding/linux-server-assignment/src(master✗) ]
    # $ dog  go.devspeed.com @127.0.0.1
    # A go.devspeed.com. 1d0h00m00s   192.168.1.29
    # [ 11:18AM ]  [ jame@Jame-Linux:~/Desktop/coding/linux-server-assignment/src(master✗) ]
    # $ dog  blog.devspeed.com @127.0.0.1
    # A blog.devspeed.com. 1d0h00m00s   192.168.1.30
    # [ 11:18AM ]  [ jame@Jame-Linux:~/Desktop/coding/linux-server-assignment/src(master✗) ]
    # $ dog  shop.devspeed.com @127.0.0.1
    # A shop.devspeed.com. 1d0h00m00s   192.168.1.31
    # [ 11:19AM ]  [ jame@Jame-Linux:~/Desktop/coding/linux-server-assignment/src(master✗) ]
    # $ dog  support.devspeed.com @127.0.0.1
    # A support.devspeed.com. 1d0h00m00s   192.168.1.32
    # [ 11:19AM ]  [ jame@Jame-Linux:~/Desktop/coding/linux-server-assignment/src(master✗) ]
    # $ dog  mail.devspeed.com @127.0.0.1
    # A mail.devspeed.com. 1d0h00m00s   192.168.1.33
    # [ 11:20AM ]  [ jame@Jame-Linux:~/Desktop/coding/linux-server-assignment/src(master✗) ]
    # $ dog  www.devspeed.com @127.0.0.1
    # A www.devspeed.com. 1d0h00m00s   192.168.1.34
    # [ 11:20AM ]  [ jame@Jame-Linux:~/Desktop/coding/linux-server-assignment/src(master✗) ]
    # $ dog  www2.devspeed.com @127.0.0.1
    # A www2.devspeed.com. 1d0h00m00s   192.168.1.100