#!/usr/bin/env bash

# +----------------------+
# | Run on one node only |
# +----------------------+

IP=$(ip -4 addr show eth0 | grep -oP 'inet \K[\d./]+' | cut -d/ -f1)

pcs host auth failover_cluster failover_cluster_2 -u hacluster

pcs cluster setup mycluster failover_cluster failover_cluster_2
pcs cluster start --all

pcs property set stonith-enabled=false
pcs property set no-quorum-policy=ignore

pcs resource create vip ocf:heartbeat:IPaddr2 \
    ip="${IP%.*}.200" \
    cidr_netmask=16 \
    nic=eth0 \
    op monitor interval=30s
    
pcs resource create web \
    systemd:nginx \
    op monitor interval=30s

pcs resource group add web-stack vip web