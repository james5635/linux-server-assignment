Failover Cluster
================

Introduction
------------

**PCS (Pacemaker/Corosync Configuration System)** is a command-line tool used to configure and manage high-availability clusters; it provides an easier interface to control cluster components. **Pacemaker** is the cluster resource manager that decides where and how services (like web servers, databases, or virtual IPs) run, ensuring they fail over automatically if a node goes down. **Corosync** is the cluster communication engine that keeps nodes connected and synchronized by handling messaging, membership, and quorum. Together, PCS configures the cluster, Corosync manages node communication, and Pacemaker controls resource availability to provide reliable high-availability systems.

Implementation
--------------

.. literalinclude:: ../../src/failover_cluster/failover_cluster.sh
   :language: bash

.. literalinclude:: ../../src/failover_cluster/failover_cluster_one_node_only.sh
   :language: bash

Usage
-----

Node1
~~~~~

.. code-block:: bash

    docker exec -it failover_cluster bash
    bash /root/failover_cluster.sh
    
    # Make sure Node2 finish
    bash /root/failover_cluster_one_node_only.sh
    
    pcs status
    ip add
    
    # +---------------+
    # | Sample Output |
    # +---------------+
    # [root@cae754b673d6 /]# pcs status
    # Cluster name: mycluster
    # Cluster Summary:
    #   * Stack: corosync (Pacemaker is running)
    #   * Current DC: failover_cluster (version 2.1.10-2.el9-5693eaeee) - partition with quorum
    #   * Last updated: Mon Mar  2 15:03:45 2026 on failover_cluster
    #   * Last change:  Mon Mar  2 15:03:30 2026 by hacluster via hacluster on failover_cluster
    #   * 2 nodes configured
    #   * 2 resource instances configured
    # 
    # Node List:
    #   * Online: [ failover_cluster failover_cluster_2 ]
    # 
    # Full List of Resources:
    #   * Resource Group: web-stack:
    #     * vip	(ocf:heartbeat:IPaddr2):	 Started failover_cluster
    #     * web	(systemd:nginx):	 Started failover_cluster
    # 
    # Daemon Status:
    #   corosync: active/disabled
    #   pacemaker: active/disabled
    #   pcsd: active/disabled
    # [root@cae754b673d6 /]# ip add
    # 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    #     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    #     inet 127.0.0.1/8 scope host lo
    #        valid_lft forever preferred_lft forever
    #     inet6 ::1/128 scope host proto kernel_lo
    #        valid_lft forever preferred_lft forever
    # 2: eth0@if93: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    #     link/ether 62:a2:a0:e9:66:b1 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    #     inet 172.18.0.3/16 brd 172.18.255.255 scope global eth0
    #        valid_lft forever preferred_lft forever
    #     inet 172.18.0.200/16 brd 172.18.255.255 scope global secondary eth0
    #        valid_lft forever preferred_lft forever
    
Node2
~~~~~

.. code-block:: bash

    docker exec -it failover_cluster_2 bash
    bash /root/failover_cluster.sh