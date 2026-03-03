File Server
===========

Introduction
------------

Samba is an open-source software suite that enables file and printer sharing between Linux/Unix systems and Windows clients using the SMB/CIFS protocol. It allows a Linux server to function as a file server, providing centralized storage, shared directories, and access control for multiple users across a network. A file server stores and manages files for clients, enabling users to read, write, and collaborate on data securely, while Samba ensures compatibility with Windows environments and seamless integration into mixed-network infrastructures.

Implementation
--------------

.. literalinclude:: ../../src/file_server/file_server.sh
   :language: bash


Usage
-----

.. code-block:: bash
    
    smbclient //localhost/shared  -N
    
    # +---------------+
    # | Sample Output |
    # +---------------+
    # jame@Jame-Linux ~/Desktop/coding/linux-server-assignment/docs % smbclient //localhost/shared  -N
    # Can't load /etc/samba/smb.conf - run testparm to debug it
    # Anonymous login successful
    # Try "help" to get a list of possible commands.
    # smb: \>