#!/bin/bash

timeout 70s tcpdump 'ip' -w pcaps/${1}.pcap --interface ${2} &
timeout 70s iperf3 -c ${3} -R -C cubic -t 60
