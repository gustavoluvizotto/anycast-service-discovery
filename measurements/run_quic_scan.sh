#!/bin/bash

if [ $# -ne 3 ]; then
    echo "Usage: $0 <input_file> <protocol_version=v4|v6> <alpn>"
    exit 1
fi

mkdir -p results/quic

INPUT_FILE=$1
PROTOCOL_VERSION=$2
ALPN=$3

# Rate limit based on leaky bucket
BUCKET_REFILL_DURATION=2
BUCKET_SIZE=500

TIMESTAMP=$(TZ=":UTC" date '+%Y%m%d%')
OUTPUT_DIR="results/quic/quic_${PROTOCOL_VERSION}_${ALPN}_${TIMESTAMP}"

if [[ "${ALPN}" == "h3" ]]; then
    ALPN_ARGUMENT="-alpn h3 -http3"
else
    ALPN_ARGUMENT="-alpn ${ALPN}"
fi

sudo sysctl -w net.core.rmem_max=7500000
sudo sysctl -w net.core.wmem_max=7500000

docker compose run --rm quic -keylog -output $OUTPUT_DIR -input $INPUT_FILE -bucket-refill-duration $BUCKET_REFILL_DURATION -bucket-size $BUCKET_SIZE ${ALPN_ARGUMENT}
RETURNCODE=$?
