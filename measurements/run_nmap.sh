#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 <input_file> <protocol_version=v4|v6>"
    exit 1
fi


mkdir -p results/nmap

INPUT_FILE=$(basename $1)
PROTOCOL_VERSION=$2
N=20  # Number of parallel scans
TIMESTAMP=$(TZ=":UTC" date '+%Y%m%d%H%M%S')
TIME_OUTPUT="nmap_time_${TIMESTAMP}.txt"

if [[ "${PROTOCOL_VERSION}" == "v6" ]]; then
    echo "Scanning IPv6 addresses"
    PROTOCOL_VERSION="-6"
else
    PROTOCOL_VERSION=""
fi

{ time \
    # https://nmap.org/book/man-performance.html
    #  -T4 prohibits the dynamic scan delay from exceeding 10 ms for TCP ports
    # --host-timeout: maximum amount of time you are willing to wait on a single host (default of T5 is 15m)
    # A host that times out is skipped. No port table, OS detection, or version detection results are printed for that host.

    # https://www.siberoloji.com/adjusting-parallelism-min-parallelism-max-parallelism-with-nmap/
    # --min-parallelism: set the minimum number of parallel probes
    docker compose run --rm nmap -T4 ${PROTOCOL_VERSION} --min-parallelism 50 --host-timeout 3m -oX "results/nmap/nmap_${TIMESTAMP}_${PROTOCOL_VERSION}.xml" -iL "input/nmap/${INPUT_FILE}" -sT -sV
} 2> results/nmap/"${TIME_OUTPUT}"
