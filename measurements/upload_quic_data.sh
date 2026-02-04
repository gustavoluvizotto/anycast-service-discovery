#!/bin/bash

PORT_NO=$1
DATASET=$2  # dataset=default (TCP scans), dataset=udp (UDP scans), dataset=quic (QUIC scans), dataset=tcp-anycast (tcp on anycast prefixes)
VP=$3  # vantage point. Format: country_alpha2-city_alpha3, e.g., nl-ens
TIMESTAMP=$4
PROTOCOL_VERSION=$5
ALPN=$6

if [ -z "$PORT_NO" ] || [ -z "$DATASET" ] || [ -z "$VP" ] || [ -z "$TIMESTAMP" ] || [ -z "$PROTOCOL_VERSION" ] || [ -z "$ALPN" ]; then
    echo "Usage: $0 <port_no> <dataset> <vantage_point> <timestamp> <protocol_version> <alpn>"
    exit 1
fi

YEAR=$(echo ${TIMESTAMP} | cut -c1-4)
MONTH=$(echo ${TIMESTAMP} | cut -c5-6)
DAY=$(echo ${TIMESTAMP} | cut -c7-8)
ALIAS_NAME="quic-write"

# ARTEFACTS
mc mv results/quic/quic_${PROTOCOL_VERSION}_${ALPN}_${TIMESTAMP}/logs "${ALIAS_NAME}/catrin/artefacts/tool=quic/dataset=${DATASET}/vp=${VP}/alpn=${ALPN}/port=${PORT_NO}/year=${YEAR}/month=${MONTH}/day=${DAY}"/logs
mc mv input/quic/zmap_responsive_udp_${PORT_NO}_${TIMESTAMP}_${PROTOCOL_VERSION}.csv "${ALIAS_NAME}/catrin/artefacts/tool=quic/dataset=${DATASET}/vp=${VP}/alpn=${ALPN}/port=${PORT_NO}/year=${YEAR}/month=${MONTH}/day=${DAY}/zmap_responsive_udp_${PORT_NO}_${TIMESTAMP}_v4.csv"

# SCAN DATA
mc mv results/quic/quic_${PROTOCOL_VERSION}_${ALPN}_${TIMESTAMP}/key.log "${ALIAS_NAME}/catrin/measurements/tool=quic/dataset=${DATASET}/vp=${VP}/alpn=${ALPN}/output=key/port=${PORT_NO}/year=${YEAR}/month=${MONTH}/day=${DAY}/key.log"

mc mv results/quic/quic_${PROTOCOL_VERSION}_${ALPN}_${TIMESTAMP}/http_header.csv "${ALIAS_NAME}/catrin/measurements/tool=quic/dataset=${DATASET}/vp=${VP}/alpn=${ALPN}/output=http_header/port=${PORT_NO}/year=${YEAR}/month=${MONTH}/day=${DAY}/http_header.csv"

mc mv results/quic/quic_${PROTOCOL_VERSION}_${ALPN}_${TIMESTAMP}/http_setting.csv "${ALIAS_NAME}/catrin/measurements/tool=quic/dataset=${DATASET}/vp=${VP}/alpn=${ALPN}/output=http_setting/port=${PORT_NO}/year=${YEAR}/month=${MONTH}/day=${DAY}/http_setting.csv"

mc mv results/quic/quic_${PROTOCOL_VERSION}_${ALPN}_${TIMESTAMP}/quic_connection_info.csv "${ALIAS_NAME}/catrin/measurements/tool=quic/dataset=${DATASET}/vp=${VP}/alpn=${ALPN}/output=quic_connection_info/port=${PORT_NO}/year=${YEAR}/month=${MONTH}/day=${DAY}/quic_connection_info.csv"

mc mv results/quic/quic_${PROTOCOL_VERSION}_${ALPN}_${TIMESTAMP}/quic_shared_config.csv "${ALIAS_NAME}/catrin/measurements/tool=quic/dataset=${DATASET}/vp=${VP}/alpn=${ALPN}/output=quic_shared_config/port=${PORT_NO}/year=${YEAR}/month=${MONTH}/day=${DAY}/quic_shared_config.csv"

mc mv results/quic/quic_${PROTOCOL_VERSION}_${ALPN}_${TIMESTAMP}/tls_certificates.csv "${ALIAS_NAME}/catrin/measurements/tool=quic/dataset=${DATASET}/vp=${VP}/alpn=${ALPN}/output=tls_certificates/port=${PORT_NO}/year=${YEAR}/month=${MONTH}/day=${DAY}/tls_certificates.csv"

mc mv results/quic/quic_${PROTOCOL_VERSION}_${ALPN}_${TIMESTAMP}/tls_shared_config.csv "${ALIAS_NAME}/catrin/measurements/tool=quic/dataset=${DATASET}/vp=${VP}/alpn=${ALPN}/output=tls_shared_config/port=${PORT_NO}/year=${YEAR}/month=${MONTH}/day=${DAY}/tls_shared_config.csv"
