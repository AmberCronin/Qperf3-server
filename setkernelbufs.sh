#!/bin/bash

[entflammen@aragonite ~]$ sysctl net.ipv4.udp_mem 
net.ipv4.udp_mem = 744417	992556	1488834
[entflammen@aragonite ~]$ sysctl net.ipv4.tcp_rmem 
net.ipv4.tcp_rmem = 4096	131072	6291456
[entflammen@aragonite ~]$ sysctl net.ipv4.tcp_wmem 
net.ipv4.tcp_wmem = 4096	16384	4194304
[entflammen@aragonite ~]$ sysctl net.ipv4.tcp_mem 
net.ipv4.tcp_mem = 372210	496278	744414
[entflammen@aragonite ~]$ sysctl net.core.rmem_max 
net.core.rmem_max = 212992
[entflammen@aragonite ~]$ sysctl net.core.wmem_max 
net.core.wmem_max = 212992
