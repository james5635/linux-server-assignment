Compose Yaml
============

The compose.yaml file defines an ambitious, all-in-one infrastructure lab that effectively functions as a "data center in a box." Utilizing CentOS Stream 9 as its primary backbone, the configuration orchestrates a massive array of services ranging from standard web and database servers (supporting PostgreSQL, MongoDB, and others) to critical networking components like VPNs, DNS, and DHCP. It even ventures into high-availability territory with failover clusters and load balancing, while relying on locally mounted shell scripts to automate the configuration of each container. It is a highly comprehensive, modular playground designed for simulating a complex enterprise environment.

.. literalinclude:: ../../compose.yaml
   :language: yaml
