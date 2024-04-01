#!/bin/bash

timeout 70s tcpdump 'ip' -s 100 -w pcaps/${1}.pcap --interface=${2} &
timeout 70s ./build-qperf/qperf --cc cubic -t 60 -l secrets/${1}-secret -c ${3} --mw ${4}
