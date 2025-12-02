#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 <input_file> <protocol_version=v4|v6>"
    exit 1
fi

mkdir -p results/zgrab

INPUT_FILE=$(basename $1)
PROTOCOL_VERSION=$2
TIMESTAMP=$(TZ=":UTC" date '+%Y%m%d%H%M%S')
TIME_OUTPUT="zgrab_time_${TIMESTAMP}.txt"

if [[ "${PROTOCOL_VERSION}" == "v4" ]]; then
    EXTRA_PARAMS="--dns-resolver=127.0.0.1:5335"
elif [[ "${PROTOCOL_VERSION}" == "v6" ]]; then
    EXTRA_PARAMS="--resolve-ipv6 --dns-resolver=[::1]:5335"  # TODO check v6 resolver
fi

time { \
    docker compose run --rm zgrab banner -f "input/zgrab/${INPUT_FILE}" -o "results/zgrab/zgrab_${TIMESTAMP}_${PROTOCOL_VERSION}.csv" #${EXTRA_PARAMS}
} 2> results/zgrab/"${TIME_OUTPUT}"
