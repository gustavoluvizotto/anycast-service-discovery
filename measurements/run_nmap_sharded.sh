#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 <shard_dir> <protocol_version=v4|v6>"
    exit 1
fi

SHARD_DIR=$1
PROTOCOL_VERSION=$2

for f in ${SHARD_DIR}/*.csv; do
    base=$(basename "$f")

    shard_num="${base#*shard_}"     # remove leading part up to "shard_"
    shard_num="${shard_num%%_of_*}" # keep everything before "_of_"

    total="${base#*_of_}"           # remove up to "_of_"
    total="${total%%_*}"            # keep everything before next "_"

    ./run_nmap.sh "$f" "$PROTOCOL_VERSION" "$shard_num" "$total"
done
