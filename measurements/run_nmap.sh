#!/bin/bash

mkdir -p results/nmap

INPUT_FILE=$1
PROTOCOL_VERSION=$2  # "4" or "6"
N=20  # Number of parallel scans
TIME_OUTPUT="nmap_time_$(date +%Y%m%d_%H%M%S).txt"

if [[ "${PROTOCOL_VERSION}" -eq 6 ]]; then
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
    docker compose run --rm nmap -T4 "${PROTOCOL_VERSION}" --min-parallelism 50 --host-timeout 3m -oX /app/results/nmap/output.xml -iL "/app/${INPUT_FILE}" -sV
} 2> results/nmap/"${TIME_OUTPUT}"
