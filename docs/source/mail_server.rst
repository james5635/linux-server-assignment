Mail Server
===========

Introduction
------------

A mail server is a system that sends, receives, stores, and manages email messages over a network using standard protocols such as SMTP for sending and POP3 or IMAP for retrieving emails. It handles user authentication, message routing, spam filtering, and mailbox storage, enabling reliable communication between individuals and organizations. Mail servers can be configured for internal communication within a company or for public internet email services, and they often include security features like encryption and authentication to protect messages in transit and at rest.

Implementation
--------------

.. literalinclude:: ../../src/backup_server/backup_server.sh
   :language: bash

Usage
-----

- open thunderbird
- username: student
- password: password
- username: testuser
- password: password
- IMAP
  - hostname: `<ip of mail server>`
  - port: 143
- SMTP
  - hostname: `<ip of mail server>`
  - port: 25