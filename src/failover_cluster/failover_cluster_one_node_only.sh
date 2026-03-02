#!/usr/bin/env bash

# +----------------------+
# | Run on one node only |
# +----------------------+

pcs host auth node1 node2 -u hacluster

pcs cluster setup mycluster node1 node2
pcs cluster start --all

pcs property set stonith-enabled=false
pcs property set no-quorum-policy=ignore

pcs resource create vip ocf:heartbeat:IPaddr2 \
    ip=172.18.0.200 \
    cidr_netmask=16 \
    nic=eth0 \
    op monitor interval=30s
    
pcs resource create web \
    systemd:nginx \
    op monitor interval=30s

pcs resource group add web-stack vip web