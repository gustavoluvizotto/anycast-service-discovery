#!/bin/bash

PROTOCOL_VERSION=$1
DATASET=$2
VP=$3
SRC_IP=$4
IFACE=$5

if [ -z "$PROTOCOL_VERSION" ] || [ -z "$DATASET" ] || [ -z "$SRC_IP" ] || [ -z "$IFACE" ] || [ -z "$VP" ]; then
    echo "Usage (this order): $0 <protocol_version=v4|v6> <dataset> <vp> <source-ip> <sendInterface>"
    exit 1
fi

TIMESTAMP=$(TZ=":UTC" date +"%Y%m%d")

# using ZMap input file; did not work well
#docker compose run --rm -T --interactive lzr ./lzr --handshakes wait,http -sendSYNs -sourceIP 145.90.8.11 -sendInterface ens2f0np0 -gatewayMac 5c:6f:69:74:ca:60 -f results/lzr/test.json -rate 500 < input/lzr/zgrabhttp_20251216.csv

# reusing ZMap results
PORTS=()
while IFS= read -r line; do
    PORTS+=("$line")
done < "input/lzr/lzr_ports.txt"

# retrieve blocklist
wget -O input/zmap/blocklist.txt "https://gitlab.utwente.nl/m7711402/internet-wide-scans/-/raw/main/blocklist.txt"
BLOCKLIST="input/zmap/blocklist.txt"

for port in "${PORTS[@]}"; do
    CLEAN_BLOCKLIST="input/zmap/blocklist_${port}.txt"

    awk -F'[:# ]' -v port="${port}" '{
        if ($2 == "")
            print $1, "  #", $5;
        else if ($2 == port)
            print $1, "  #", $6;
    }' < "${BLOCKLIST}" > "${CLEAN_BLOCKLIST}"

    # create zmap allowlist...
    YEAR=$(echo ${TIMESTAMP} | cut -c1-4)
    MONTH=$(echo ${TIMESTAMP} | cut -c5-6)
    DAY=$(echo ${TIMESTAMP} | cut -c7-8)
    zmap_input_file="input/zmap/anycast_prefixes_${YEAR}_${MONTH}_${DAY}_${PROTOCOL_VERSION}.csv"
    if [ ! -f "${zmap_input_file}" ]; then
        echo "Generating ZMap input file: ${zmap_input_file}"
        ../venv/bin/python ../census_helper.py --ip-version ${PROTOCOL_VERSION} --date ${TIMESTAMP} --output-dir input/zmap/ --prefixes-only
    fi

    zmap_output_file="results/zmap/zmap_${port}_${TIMESTAMP}.jsonl"
    ZMAP_EXTRA_PARAMS=""
    # ZMap UDP module probes:
    # https://github.com/zmap/zmap/tree/main/examples/udp-probes
    # these ports must run separately and manually because of the iptables rule of LZR that has to be undone
    if [ $port == "53" ]; then
        ZMAP_EXTRA_PARAMS="-M udp --probe-args=file:input/zmap/dns_53.pkt"
        udp_dataset=udp$(echo ${DATASET} | sed 's/tcp//Ig')
    elif [ $port == "123" ]; then
        ZMAP_EXTRA_PARAMS="-M udp --probe-args=file:input/zmap/ntp_123.pkt"
        udp_dataset=udp$(echo ${DATASET} | sed 's/tcp//Ig')
    fi
    if [ $port == "53" ] || [ $port == "123" ]; then
        zmap_time_output="results/zmap/zmap_time_${port}_${TIMESTAMP}.txt"
        # run zmap!
        echo "Running ZMap for port ${port}..."
        { time \
            docker compose run --rm \
            zmap -b ${CLEAN_BLOCKLIST} -B 50M -p "${port}" -w "${zmap_input_file}" ${ZMAP_EXTRA_PARAMS} \
                -o "${zmap_output_file}" -O json -f "saddr,ttl" \
                --output-filter="success=1 && repeat=0";
        } 2> "${zmap_time_output}"

        ./upload_zmap_data.sh "${port}" "${udp_dataset}" "${VP}" "${TIMESTAMP}" "${PROTOCOL_VERSION}"
        # no need to run zgrab for UDP ports...
        continue
    fi

    sudo iptables -A OUTPUT -p tcp --tcp-flags RST RST -s ${SRC_IP} -j DROP
    log_file="results/lzr/lzr_${port}_${TIMESTAMP}.log"
    output_file="results/lzr/lzr_${port}_${TIMESTAMP}.jsonl"
    HS=$(../venv/bin/python3 lzr_port_handshake.py --port "${port}")

    docker compose run --rm -T --interactive \
        zmap -b ${CLEAN_BLOCKLIST} -p "${port}" -w "${zmap_input_file}" --source-ip="${SRC_IP}" \
        -f "saddr,daddr,sport,dport,seqnum,acknum,window,ttl" -O json \
        --output-filter="success=1 && repeat=0" \
    | tee "${zmap_output_file}" \
    | docker compose run --rm -T --interactive \
        lzr ./lzr --handshakes "${HS}" -sendInterface "${IFACE}" -t 10 -f "${output_file}" &> "${log_file}"

    # upload all data
    ./upload_zmap_data.sh "${port}" "${DATASET}" "${VP}" "${TIMESTAMP}" "${PROTOCOL_VERSION}"
    ./upload_lzr_data.sh "${port}" "${DATASET}" "${VP}" "${TIMESTAMP}" "${PROTOCOL_VERSION}"
    sudo iptables -D OUTPUT 1
done
