FTP Server
==========

Introduction
------------

An FTP server is a system that uses the File Transfer Protocol (FTP) to allow users to upload, download, and manage files over a network. It enables file sharing between clients and a central server using authentication with usernames and passwords, and can support both anonymous and secure access configurations. FTP servers are commonly used for website file management, internal file distribution, and data exchange between systems, and can be secured using extensions like FTPS to encrypt data during transmission.

Implementation
--------------

.. literalinclude:: ../../src/ftp_server/ftp_server.sh
   :language: bash


Usage
-----

- use filezilla (port 21)
- username: ftpuser
- password: password