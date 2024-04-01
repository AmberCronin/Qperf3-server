#!/bin/bash

sudo docker run -dti --name rout --sysctl net.ipv4.tcp_rmem="200000000 200000000 200000000" --sysctl net.ipv4.tcp_wmem="200000000 200000000 200000000" --sysctl net.ipv4.ip_forward=1 qperf-router > container.id


# --sysctl net.ipv4.tcp_rmem="200000000 200000000 200000000" --sysctl net.ipv4.tcp_wmem="200000000 200000000 200000000"