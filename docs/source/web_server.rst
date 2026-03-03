Web Server
==========

Introduction
------------

Apache HTTP Server, often called Apache httpd, is a widely used open-source web server that delivers web content to clients over the Internet using the HTTP and HTTPS protocols. It handles requests from browsers, serves static and dynamic content, supports modules for features like URL rewriting, authentication, and SSL/TLS encryption, and can host multiple websites on a single server. A web server, in general, is responsible for processing client requests, managing resources, and ensuring reliable delivery of web pages, applications, and services to users.

Implementation
--------------

.. literalinclude:: ../../src/web_server/web_server.sh
   :language: bash

Usage
-----

- open firefox and visit `http://localhost/`
- curl `http://localhost/`