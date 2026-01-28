#!/bin/bash

PORT=$1
DATASET=$2
VP=$3
TIMESTAMP=$4
PROTOCOL_VERSION=$5

if [ -z "$PORT" ] || [ -z "$DATASET" ] || [ -z "$VP" ] || [ -z "$TIMESTAMP" ] || [ -z "$PROTOCOL_VERSION" ]; then
    echo "Usage (this order): $0 <port> <dataset> <vp> <timestamp> <protocol_version>"
    exit 1
fi

ALIAS="lzr-write"
BUCKET_NAME="catrin"
YEAR=${TIMESTAMP:0:4}
MONTH=${TIMESTAMP:4:2}
DAY=${TIMESTAMP:6:2}

mc mv --no-color --dp "results/lzr/lzr_${PORT}_${TIMESTAMP}.jsonl" "${ALIAS}/${BUCKET_NAME}/measurements/tool=lzr/dataset=${DATASET}/format=raw/vp=${VP}/port=${PORT}/year=${YEAR}/month=${MONTH}/day=${DAY}/lzr_${PORT}_${TIMESTAMP}.jsonl"

mc mv --no-color --dp "results/lzr/lzr_${PORT}_${TIMESTAMP}.log" "${ALIAS}/${BUCKET_NAME}/artefacts/tool=lzr/dataset=${DATASET}/vp=${VP}/port=${PORT}/year=${YEAR}/month=${MONTH}/day=${DAY}/lzr_${PORT}_${TIMESTAMP}.log"
