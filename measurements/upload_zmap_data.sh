#!/bin/bash

# inspired by
# https://gitlab.utwente.nl/m7711402/internet-wide-scans/-/blob/main/transfer_to_objstore.sh

PORT_NO=$1
DATASET=$2  # dataset=default (TCP scans), dataset=udp (UDP scans), dataset=quic (QUIC scans), dataset=tcp-anycast (tcp on anycast prefixes)
VP=$3  # vantage point. Format: country_alpha2-city_alpha3, e.g., nl-ens
TIMESTAMP=$4
PROTOCOL_VERSION=$5

if [ -z "$PORT_NO" ] || [ -z "$DATASET" ] || [ -z "$VP" ] || [ -z "$TIMESTAMP" ] || [ -z "$PROTOCOL_VERSION" ]; then
    echo "Usage: $0 <port_no> <dataset> <vantage_point> <timestamp> <protocol_version>"
    exit 1
fi

YEAR=$(echo ${TIMESTAMP} | cut -c1-4)
MONTH=$(echo ${TIMESTAMP} | cut -c5-6)
DAY=$(echo ${TIMESTAMP} | cut -c7-8)
ALIAS_NAME="zmap-write"
SCAN_OBJSTORE_PATH="${ALIAS_NAME}/catrin/measurements/tool=zmap/dataset=${DATASET}/vp=${VP}/port=${PORT_NO}/year=${YEAR}/month=${MONTH}/day=${DAY}"
ARTIFACT_OBJSTORE_PATH="${ALIAS_NAME}/catrin/artefacts/tool=zmap/dataset=${DATASET}/vp=${VP}/port=${PORT_NO}/year=${YEAR}/month=${MONTH}/day=${DAY}"

# SCAN DATA
mc mv --no-color --dp results/zmap/zmap_${PORT_NO}_${TIMESTAMP}.jsonl "${SCAN_OBJSTORE_PATH}/zmap_${PORT_NO}_${TIMESTAMP}.jsonl"

# ARTEFACTS
mc cp --no-color --dp input/zmap/anycast_prefixes_${YEAR}_${MONTH}_${DAY}_${PROTOCOL_VERSION}.csv "${ARTIFACT_OBJSTORE_PATH}/anycast_prefixes_${YEAR}_${MONTH}_${DAY}_${PROTOCOL_VERSION}.csv"

mc cp --no-color --dp input/zmap/blocklist_${PORT_NO}.txt "${ARTIFACT_OBJSTORE_PATH}/blocklist_${PORT_NO}.txt"

if [ -f results/zmap/zmap_time_${PORT_NO}_${TIMESTAMP}.txt ]; then
    mc mv --no-color --dp results/zmap/zmap_time_${PORT_NO}_${TIMESTAMP}.txt "${ARTIFACT_OBJSTORE_PATH}/zmap_time_${PORT_NO}_${TIMESTAMP}.txt"
fi
