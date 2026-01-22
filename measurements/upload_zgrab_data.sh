#!/bin/bash

PORT_NO=$1
DATASET=$2  # dataset=default (TCP scans), dataset=udp (UDP scans), dataset=quic (QUIC scans), dataset=tcp-anycast (tcp on anycast prefixes)
VP=$3  # vantage point. Format: country_alpha2-city_alpha3, e.g., nl-ens
TIMESTAMP=$4
PROTOCOL_VERSION=$5
INPUT_FILE=$6

if [ -z "$PORT_NO" ] || [ -z "$DATASET" ] || [ -z "$VP" ] || [ -z "$TIMESTAMP" ] || [ -z "$PROTOCOL_VERSION" ] || [ -z "$INPUT_FILE" ]; then
    echo "Usage: $0 <port_no> <dataset> <vantage_point> <timestamp> <protocol_version> <input_file>"
    exit 1
fi

YEAR=$(echo ${TIMESTAMP} | cut -c1-4)
MONTH=$(echo ${TIMESTAMP} | cut -c5-6)
DAY=$(echo ${TIMESTAMP} | cut -c7-8)
ALIAS_NAME="zgrab-write"
SCAN_OBJSTORE_PATH="${ALIAS_NAME}/catrin/measurements/tool=zgrab/dataset=${DATASET}/format=raw/vp=${VP}/port=${PORT_NO}/year=${YEAR}/month=${MONTH}/day=${DAY}"
ARTIFACT_OBJSTORE_PATH="${ALIAS_NAME}/catrin/artefacts/tool=zgrab/dataset=${DATASET}/vp=${VP}/port=${PORT_NO}/year=${YEAR}/month=${MONTH}/day=${DAY}"


# measurements
mc mv --no-color --dp results/zgrab/zgrab_${PORT_NO}_${TIMESTAMP}_${PROTOCOL_VERSION}.jsonl "${SCAN_OBJSTORE_PATH}/zgrab_${PORT_NO}_${TIMESTAMP}_${PROTOCOL_VERSION}.jsonl"

# artefacts
mc mv --no-color --dp results/zgrab/zgrab_${PORT_NO}_${TIMESTAMP}_${PROTOCOL_VERSION}.log "${ARTIFACT_OBJSTORE_PATH}/zgrab_${PORT_NO}_${TIMESTAMP}_${PROTOCOL_VERSION}.log"

mc mv --no-color --dp results/zgrab/zgrab_time_${PORT_NO}_${TIMESTAMP}.txt "${ARTIFACT_OBJSTORE_PATH}/zgrab_time_${PORT_NO}_${TIMESTAMP}.txt"

mc mv --no-color --dp "${INPUT_FILE}" "${ARTIFACT_OBJSTORE_PATH}/$(basename "${INPUT_FILE}")"
mc cp --no-color --dp input/zgrab/zgrab_config.ini "${ARTIFACT_OBJSTORE_PATH}/zgrab_config.ini"
