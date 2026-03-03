Docker
======

Introduction
------------

Docker is an open-source containerization platform that allows developers to package applications and their dependencies into lightweight, portable containers that run consistently across different environments. Instead of relying on full virtual machines, Docker uses operating system–level virtualization to isolate applications while sharing the host kernel, making it faster and more resource-efficient. It simplifies development, testing, and deployment workflows by ensuring that applications behave the same way on a developer’s laptop, a server, or in the cloud.

Implementation
--------------

.. literalinclude:: ../../src/docker/docker.sh
   :language: bash

   
Usage
-----

ssh to `root@localhost` with port 8081 and password 'password'