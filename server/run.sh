#!/bin/bash

sudo docker run -dti --name serv --sysctl net.ipv4.tcp_rmem="200000000 200000000 200000000" --sysctl net.ipv4.tcp_wmem="200000000 200000000 200000000" qperf-server > container.id