#!/bin/bash

OUTPUT_FILE=$1
LOG_FILE=$2
TIMESTAMP=$3
PORT=$4
VP=$5

ALIAS="lzr-write"
BUCKET_NAME="catrin"
YEAR=${TIMESTAMP:0:4}
MONTH=${TIMESTAMP:4:2}
DAY=${TIMESTAMP:6:2}
FILENAME=$(basename ${OUTPUT_FILE})
LOG_FILENAME=$(basename ${LOG_FILE})

if [ -z "$OUTPUT_FILE" ] || [ -z "$LOG_FILE" ] || [ -z "$TIMESTAMP" ] || [ -z "$PORT" ] || [ -z "$VP" ]; then
    echo "Usage: $0 <lzr_output_file> <lzr_log_file> <timestamp> <port> <vp>"
    exit 1
fi

mc mv --no-color --dp "${OUTPUT_FILE}" "${ALIAS}/${BUCKET_NAME}"/measurements/tool=lzr/dataset=anycast/format=raw/vp="${VP}"/port="${PORT}"/year="${YEAR}"/month="${MONTH}"/day="${DAY}"/"${FILENAME}"
mc mv --no-color --dp "${LOG_FILE}" "${ALIAS}/${BUCKET_NAME}"/artefacts/tool=lzr/dataset=anycast/vp="${VP}"/port="${PORT}"/year="${YEAR}"/month="${MONTH}"/day="${DAY}"/"${LOG_FILENAME}"
