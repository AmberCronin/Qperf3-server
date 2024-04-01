#!/bin/bash

timeout 45s tcpdump 'ip' -w pcaps/${1}.pcap --interface ${2} &
iperf3 -s -1

