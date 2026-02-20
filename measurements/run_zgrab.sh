#!/bin/bash

mkdir -p results/zgrab

PROTOCOL_VERSION=$1
DATASET=$2
VP=$3

if [ -z $PROTOCOL_VERSION ] || [ -z $DATASET ] || [ -z $VP ]; then
    echo "Usage (this order): $0 <protocol_version=v4|v6> <dataset> <vp>"
    exit 1
fi

ZGRAB_GOROUTINES=500
TIMESTAMP=$(TZ=":UTC" date '+%Y%m%d')

YEAR=$(echo ${TIMESTAMP} | cut -c1-4)
MONTH=$(echo ${TIMESTAMP} | cut -c5-6)
DAY=$(echo ${TIMESTAMP} | cut -c7-8)

port="all_ports"

zgrab_input_file="input/zgrab/..." # TODO
zgrab_output_dir="results/zgrab"
zgrab_time_output="${zgrab_output_dir}/zgrab_time_${port}_${TIMESTAMP}.txt"
zgrab_output_file="${zgrab_output_dir}/zgrab_${port}_${TIMESTAMP}_${PROTOCOL_VERSION}.jsonl"
zgrab_log_file="${zgrab_output_dir}/zgrab_${port}_${TIMESTAMP}_${PROTOCOL_VERSION}.log"
echo "Running ZGrab for port ${port}..."
{ time  \
    docker compose run --rm \
    zgrab multiple -c input/zgrab/zgrab_config.ini -f "${zgrab_input_file}" \
        -o "${zgrab_output_file}" -s ${ZGRAB_GOROUTINES} &> "${zgrab_log_file}";
} &> "${zgrab_time_output}"

# upload all data
./upload_zgrab_data.sh "${port}" "${DATASET}" "${VP}" "${TIMESTAMP}" "${PROTOCOL_VERSION}" "${zgrab_input_file}"
