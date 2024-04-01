#!/bin/bash

timeout 45s tcpdump 'ip' -w pcaps/${1}.pcap --interface ${2} &
timeout 45s sudo ping -i 0.02 ${3} > pcaps/${1}.pings &
timeout 45s iperf3 -c ${3} -R -C cubic -t 30
