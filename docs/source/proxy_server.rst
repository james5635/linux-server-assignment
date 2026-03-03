Proxy Server
============

Introduction
------------

Squid is a caching and forwarding proxy server that handles web requests on behalf of clients, improving performance and controlling access to the internet. By storing frequently accessed content locally, Squid reduces bandwidth usage and speeds up response times for repeated requests. A proxy server acts as an intermediary between client devices and external servers, providing benefits like content filtering, anonymity, security, and traffic management, making it useful for organizations to optimize and regulate internet access.

Implementation
--------------

.. literalinclude:: ../../src/proxy_server/proxy_server.sh
   :language: bash

Usage
-----

Open firefox and change proxy to localhost with port 3128

- visit youtube.com => allow
- visit facebook.com => blocked