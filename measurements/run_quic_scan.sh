#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 <input_file> <protocol_version=v4|v6>"
    exit 1
fi

mkdir -p results/quic

INPUT_FILE=$1
PROTOCOL_VERSION=$2

# Rate limit based on leaky bucket
BUCKET_REFILL_DURATION=2
BUCKET_SIZE=500

TIMESTAMP=$(TZ=":UTC" date '+%Y%m%d%H%M%S')
OUTPUT_DIR="results/quic/quic_${PROTOCOL_VERSION}_${TIMESTAMP}"

sysctl -w net.core.rmem_max=7500000
sysctl -w net.core.wmem_max=7500000

docker compose run --rm quic -keylog -output $OUTPUT_DIR -input $INPUT_FILE -bucket-refill-duration $BUCKET_REFILL_DURATION -bucket-size $BUCKET_SIZE 
RETURNCODE=$?
