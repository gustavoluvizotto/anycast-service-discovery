#!/bin/bash

SHARD_DIR=$1

for f in ${SHARD_DIR}/*.csv; do
    base=$(basename "$f")

    shard_num="${base#*shard_}"     # remove leading part up to "shard_"
    shard_num="${shard_num%%_of_*}" # keep everything before "_of_"

    total="${base#*_of_}"           # remove up to "_of_"
    total="${total%%_*}"            # keep everything before next "_"

    ./run_nmap.sh $f v4 $shard_num $total
done

