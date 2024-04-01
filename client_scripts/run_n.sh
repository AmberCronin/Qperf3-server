#!/bin/bash
for j in search10delv; do mkdir -p ${j}_${1}; done
for ((i = 1; i <= ${3}; i++)); do for j in search10delv; do sudo ./run_quic_ss_test_client_ping.sh quic-${j}_${1}-${i} veth0 192.168.4.1 & sleep ${2}; done; done
