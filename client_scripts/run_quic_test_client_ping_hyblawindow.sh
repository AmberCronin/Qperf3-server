#!/bin/bash


TIMEOUT=60
RUNTIME=50

timeout ${TIMEOUT}s tcpdump 'ip' -s 100 -w pcaps/${1}.pcap --interface=${2} &
timeout ${TIMEOUT}s sudo ping -i 0.02 ${3} > pcaps/${1}.pings &
timeout ${TIMEOUT}s ./build-qperf/qperf --cc cubic --cmdg hybla -t ${RUNTIME} -l secrets/${1}-secret -c ${3} --mw 60 | tee pcaps/${1}.log

