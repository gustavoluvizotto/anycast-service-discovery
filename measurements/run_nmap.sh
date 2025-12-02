#!/bin/bash

if [ $# -lt 2 ] || [ $# -gt 4 ]; then
    echo "Usage: $0 <input_file> <protocol_version=v4|v6> [shard] [nshard]"
    exit 1
fi

SHARD=""
NSHARD=""
SHARD_TXT=""
if [ -z "$3" ] && [ -z "$4" ]; then
    echo "Sharding not enabled"
else
    echo "Sharding enabled: shard=$3 nshard=$4"
    SHARD=$3  # optional
    NSHARD=$4  # optional
    SHARD_TXT="_${SHARD}_of_${NSHARD}_"
fi

mkdir -p results/nmap

INPUT_FILE=$(basename $1)
PROTOCOL_VERSION=$2
TIMESTAMP=$(TZ=":UTC" date '+%Y%m%d%H%M%S')
TIME_OUTPUT="nmap_time_${TIMESTAMP}${SHARD_TXT}.txt"

if [[ "${PROTOCOL_VERSION}" == "v6" ]]; then
    echo "Scanning IPv6 addresses"
    PROTOCOL_VERSION="-6"
else
    PROTOCOL_VERSION=""
fi

{ time \
    # https://nmap.org/book/man-performance.html
    # https://www.siberoloji.com/adjusting-parallelism-min-parallelism-max-parallelism-with-nmap/
    docker compose run --rm nmap -T4 ${PROTOCOL_VERSION} --script='' --max-retries 3 --min-parallelism 40 --host-timeout 2m --top-ports 2000 -oX "results/nmap/nmap_${TIMESTAMP}_${PROTOCOL_VERSION}${SHARD_TXT}.xml" -iL "input/nmap/${INPUT_FILE}" -n -sS
} 2> results/nmap/"${TIME_OUTPUT}"
