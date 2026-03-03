Backup Server
=============

Introduction
------------

Cronie is a time-based job scheduler for Linux systems that runs background tasks automatically at specified times using crontab configuration files, making it ideal for routine system maintenance like log rotation, updates, and automated backups. A backup server is a dedicated system designed to store copies of data from other machines to protect against data loss caused by hardware failure, human error, cyberattacks, or disasters; it centralizes backup management and enables recovery of files, databases, or entire systems when needed. Together, Cronie can automate scheduled backup tasks, while the backup server securely stores and manages the backup data.

Implementation
--------------

.. literalinclude:: ../../src/backup_server/backup_server.sh
   :language: bash


Usage
-----

The backup server will backup ftp server every one minute.

.. code-block:: bash
    
    docker exec -it baclup_server bash
    ls /backup
    cat /log.txt