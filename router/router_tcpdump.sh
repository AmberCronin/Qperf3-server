#!/bin/bash

mkdir -p pcaps
timeout 70s tcpdump 'ip' -s 100 -w pcaps/veth1-${1}.pcap --interface=veth1 &
timeout 70s tcpdump 'ip' -s 100 -w pcaps/veth2-${1}.pcap --interface=veth2 &