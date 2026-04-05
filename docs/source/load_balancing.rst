Load Balancing
==============

Introduction
------------

Load balancing is a technique used to distribute incoming network traffic or application requests across multiple servers to ensure no single server becomes overloaded. By spreading workloads evenly, it improves system performance, reliability, and availability, especially in high-traffic environments. Load balancers can operate at different layers of the network (such as transport or application layer) and may use methods like round-robin, least connections, or IP hashing to decide how requests are distributed.

Implementation
--------------

.. literalinclude:: ../../src/load_balancing/load_balancing.sh
   :language: bash

Usage
-----
   
vist `http://<ip of load balancing>:81`

.. figure:: _static/load_balancing.png

.. figure:: _static/load_balancing_2.png
