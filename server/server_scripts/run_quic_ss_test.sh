#!/bin/bash

timeout 45s tcpdump 'ip' -s 100 -w pcaps/serv-${1}.pcap --interface=${2} &
timeout 40s ./build-qperf/qperf --cc cubic -s --mw 60 --ss ${3} -l secrets/${1}-secret

