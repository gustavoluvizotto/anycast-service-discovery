#!/bin/bash

mkdir -p results/zgrab

PROTOCOL_VERSION=$1
DATASET=$2
VP=$3

if [ -z $PROTOCOL_VERSION ] || [ -z $DATASET ] || [ -z $VP ]; then
    echo "Usage: $0 <protocol_version=v4|v6> <dataset> <vp>"
    exit 1
fi

ZGRAB_GOROUTINES=5000
ZGRAB_READ_LIMIT_PER_HOST=2  # in KB
TIMESTAMP=$(TZ=":UTC" date '+%Y%m%d')
PORTS=()
while IFS= read -r line; do
    PORTS+=("$line")
done < "input/zgrab/test_ports.txt"

EXTRA_PARAMS=""
#if [[ "${PROTOCOL_VERSION}" == "v4" ]]; then
#    EXTRA_PARAMS="--dns-resolvers=127.0.0.1:5335"
#elif [[ "${PROTOCOL_VERSION}" == "v6" ]]; then
#    EXTRA_PARAMS="--resolve-ipv6 --dns-resolvers=[::1]:5335"
#fi

for port in "${PORTS[@]}"; do
    # create zmap allowlist...

    YEAR=$(echo ${TIMESTAMP} | cut -c1-4)
    MONTH=$(echo ${TIMESTAMP} | cut -c5-6)
    DAY=$(echo ${TIMESTAMP} | cut -c7-8)
    zmap_input_file="input/zmap/anycast_prefixes_${YEAR}_${MONTH}_${DAY}_${PROTOCOL_VERSION}.csv"
    if [ ! -f "${zmap_input_file}" ]; then
        echo "Generating ZMap input file: ${zmap_input_file}"
        python ../census_helper.py --ip-version ${PROTOCOL_VERSION} --date ${TIMESTAMP} --output-dir input/zmap/ --prefixes-only
    fi

    zmap_output_dir="results/zmap"
    zmap_output_file="${zmap_output_dir}/zmap_${port}_${TIMESTAMP}.csv"
    zmap_time_output="${zmap_output_dir}/zmap_time_${port}_${TIMESTAMP}.txt"
    mkdir -p "${zmap_output_dir}"
    # run zmap!
    echo "Running ZMap for port ${port}..."
    { time \
        docker compose run --rm \
        zmap -B 50M -p "${port}" -w "${zmap_input_file}" \
            -o "${zmap_output_file}" -O csv \
            --output-filter="success=1 && repeat=0";
    } 2> "${zmap_time_output}"

    # run below if ZMap data is uploaded to objstore
    #python retrieve_zmap_allowlist.py --timestamp ${TIMESTAMP} --port ${port} --dataset ${DATASET} --vp ${VP}

    zgrab_input_file=$(python prepare_zgrab_input.py --timestamp ${TIMESTAMP} --port ${port} --dataset ${DATASET} --vp ${VP} --zmap-file "${zmap_output_file}")

    zgrab_output_dir="results/zgrab"
    zgrab_time_output="${zgrab_output_dir}/zgrab_time_${port}_${TIMESTAMP}.txt"
    zgrab_output_file="${zgrab_output_dir}/zgrab_${port}_${TIMESTAMP}_${PROTOCOL_VERSION}.jsonl"
    zgrab_log_file="${zgrab_output_dir}/zgrab_${port}_${TIMESTAMP}_${PROTOCOL_VERSION}.log"
    echo "Running ZGrab for port ${port}..."
    { time  \
        docker compose run --rm \
        zgrab multiple -c input/zgrab/zgrab_config.ini -f "${zgrab_input_file}" \
            -o "${zgrab_output_file}" -s ${ZGRAB_GOROUTINES} \
            --read-limit-per-host=${ZGRAB_READ_LIMIT_PER_HOST} &> "${zgrab_log_file}";
    } &> "${zgrab_time_output}"

    # upload all data
    #./upload_zmap_data.sh "${port}" "${DATASET}" "${VP}" "${TIMESTAMP}" "${PROTOCOL_VERSION}"
    #./upload_zgrab_data.sh "${port}" "${DATASET}" "${VP}" "${TIMESTAMP}" "${PROTOCOL_VERSION}" "${zgrab_input_file}"
done
