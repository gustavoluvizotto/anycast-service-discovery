#!/bin/bash

time { \
    docker compose run --rm zgrab2 -f "input/zgrab/${INPUT_FILE}" -o "results/zgrab/zgrab_${PORT}_${TIMESTAMP}_${PROTOCOL_VERSION}.csv"
} 2> results/zgrab/"${TIME_OUTPUT}"
