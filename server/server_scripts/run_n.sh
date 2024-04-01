#!/bin/bash
for j in search10delv; do mkdir -p ${j}_${1}; done
for ((i = 1; i <= ${3}; i++)); do for j in search10delv; do sudo ./run_quic_ss_test.sh quic-${j}_${1}-${i} veth3 ${j} | tee ${j}_${1}/${j}_${1}-${i}-out.csv & sleep ${2}; done; done
