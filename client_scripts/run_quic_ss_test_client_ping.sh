#!/bin/bash

timeout 45s tcpdump 'ip' -s 100 -w pcaps/${1}.pcap --interface=${2} &
timeout 45s sudo ping -i 0.02 ${3} > pcaps/${1}.pings &
timeout 40s ./build-qperf/qperf --cc cubic -t 30 --cmdg hybla -l secrets/${1}-secret -c ${3} --mw 60
