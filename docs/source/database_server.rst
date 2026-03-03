Database Server
===============

Introduction
------------

PostgreSQL, MongoDB, and Microsoft SQL Server are popular database management systems that store, organize, and manage data for applications. PostgreSQL and SQL Server are relational databases that use structured schemas and SQL queries for reliable transaction processing, while MongoDB is a NoSQL database optimized for flexible, document-oriented storage. A database server provides centralized data management, allowing multiple clients or applications to securely read, write, and manipulate data efficiently, ensuring consistency, availability, and scalability.

Implementation
--------------

.. literalinclude:: ../../src/database_server/database_server.sh
   :language: bash

PostgreSQL
~~~~~~~~~~

.. literalinclude:: ../../src/database_server/postgresql.sh
   :language: bash

MongoDB
~~~~~~~

.. literalinclude:: ../../src/database_server/mongodb.sh
   :language: bash

SQL Server
~~~~~~~~~~

.. literalinclude:: ../../src/database_server/sql_server.sh
   :language: bash

Usage
-----

PostgreSQL
~~~~~~~~~~

.. code-block:: bash
    
    psql -h localhost -p 5432 -U postgres
    
    # +---------------+
    # | Sample Output |
    # +---------------+
    # jame@Jame-Linux ~/Desktop/coding/linux-server-assignment/docs % psql -h localhost -p 5432 -U postgres
    # psql (18.2, server 13.23)
    # Type "help" for help.
    # 
    # postgres=#

MongoDB
~~~~~~~

.. code-block:: bash
    
    mongosh
    
    # +---------------+
    # | Sample Output |
    # +---------------+
    # root@Jame-Linux:/# mongosh
    # Current Mongosh Log ID:	69a672534c3090e902d861df
    # Connecting to:		mongodb://127.0.0.1:27017/?directConnection=true&serverSelectionTimeoutMS=2000&appName=mongosh+2.5.0
    # Using MongoDB:		7.0.30
    # Using Mongosh:		2.5.0
    # 
    # For mongosh info see: https://www.mongodb.com/docs/mongodb-shell/
    # 
    # 
    # To help improve our products, anonymous usage data is collected and sent to MongoDB periodically (https://www.mongodb.com/legal/privacy-policy).
    # You can opt-out by running the disableTelemetry() command.
    # 
    # ------
    #    The server generated these startup warnings when booting
    #    2026-03-03T05:30:00.834+00:00: Access control is not enabled for the database. Read and write access to data and configuration is unrestricted
    #    2026-03-03T05:30:00.835+00:00: You are running this process as the root user, which is not recommended
    #    2026-03-03T05:30:00.835+00:00: Soft rlimits for open file descriptors too low
    #    2026-03-03T05:30:00.835+00:00: For customers running MongoDB 7.0, we suggest changing the contents of the following sysfsFile
    # ------
    # 
    # test>
    
    
SQL Server
~~~~~~~~~~

.. code-block:: bash
    
    /opt/mssql-tools18/bin/sqlcmd -S localhost -C -U sa -P 'YourStrong!Password'
    
    # +---------------+
    # | Sample Output |
    # +---------------+
    # [root@Jame-Linux /]# /opt/mssql-tools18/bin/sqlcmd -S localhost -C -U sa -P 'YourStrong!Password'
    # 1> CREATE TABLE cat(name varchar(100), age int)
    # 2> GO
    # 1> INSERT INTO cat VALUES('moo', 12)
    # 2> GO
    # 
    # (1 rows affected)
    # 1> SELECT * FROM cat
    # 2> GO
    # name                                                                                                 age
    # ---------------------------------------------------------------------------------------------------- -----------
    # moo                                                                                                           12
    # 
    # (1 rows affected)
    # 1>