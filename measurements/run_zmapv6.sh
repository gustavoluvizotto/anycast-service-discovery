#!/bin/bash

INPUT_FILE=$1
ZMAPV6_DIR="${HOME}/data/workspace/zmapv6/install/sbin"
TIMESTAMP=$(date +"%Y%m%d")

declare -a PORTS=(
"443"
"853"
)

for PORT_NO in "${PORTS[@]}"; do
    echo "Scanning ${ALLOWLIST_FILENAME} port:${PORT_NO}..."
    ${ZMAPV6_DIR}/zmap --interface=ens2f0np0 --gateway-mac="5c:6f:69:74:ca:60" -M udp --probe-args=file:input/zmap/initial_qscanner_1a1a1a1a.pkt --ipv6-source-ip=fe80::5e6f:69ff:fe74:ca60 --ipv6-target-file="${INPUT_FILE}" -B 30M -p "${PORT_NO}" -o results/zmap/zmap_${PORT_NO}_${TIMESTAMP}_v6.csv -O csv --output-filter="success=1 && repeat=0"
done

