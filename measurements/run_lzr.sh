#!/bin/bash

INPUT_FILE=$1
SRC_IP=$2
IFACE=$3

if [ -z "$INPUT_FILE" ] || [ -z "$SRC_IP" ] || [ -z "$IFACE" ]; then
    echo "Usage: $0 <zmap_allowlist_file> <source-ip> <sendInterface>"
    exit 1
fi

TIMESTAMP=$(date +"%Y%m%d")
PORTS_FILE="input/lzr/lzr_ports.txt"

# using ZMap input file; did not work well
#docker compose run --rm -T --interactive lzr ./lzr --handshakes wait,http -sendSYNs -sourceIP 145.90.8.11 -sendInterface ens2f0np0 -gatewayMac 5c:6f:69:74:ca:60 -f results/lzr/test.json -rate 500 < input/lzr/zgrabhttp_20251216.csv

# reusing ZMap results
PORTS=()
while IFS= read -r line; do
    PORTS+=("$line")
done < "$PORTS_FILE"

# ZMap UDP module probes:
# https://github.com/zmap/zmap/tree/main/examples/udp-probes
# scan these separately because LZR doesn't have NTP and DNS is commonly on UDP
#MODULE=""
#if [ "${port}" -eq 123 ]; then
#    MODULE="-M udp --probe-args=file:input/zmap/ntp_123.pkt"
#fi
#if [ "${port}" -eq 53 ]; then
#    MODULE="-M udp --probe-args=file:input/zmap/dns_53.pkt"
#fi

for port in "${PORTS[@]}"; do
    log_file="results/lzr/lzr_${port}_${TIMESTAMP}.log"
    output_file="results/lzr/lzr_${port}_${TIMESTAMP}.jsonl"
    HS=$(python3 lzr_port_handshake.py --port "${port}")

    docker compose run --rm -T --interactive zmap -p "${port}" -w "${INPUT_FILE}" --source-ip="${SRC_IP}" -f "saddr,daddr,sport,dport,seqnum,acknum,window" -O json --output-filter="success=1 && repeat=0" | docker compose run --rm -T --interactive lzr ./lzr --handshakes "${HS}" -sendInterface "${IFACE}" -f "${output_file}" &> "${log_file}"
done
