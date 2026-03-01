Domain Controller
=================

Introduction
------------
FreeIPA is a free, open-source Identity Management (IdM) solution designed primarily for Linux and Unix-based networked environments. Often described as the Linux equivalent of Microsoft Active Directory, it provides a centralized platform for managing authentication, authorization, and network policies.

Implementation
--------------

.. literalinclude:: ../../src/domain_controller/domain_controller.sh
   :language: bash

   
Usage
-----

.. code-block::

    docker exec -it centos9_systemd bash
    su admin
    su testuser