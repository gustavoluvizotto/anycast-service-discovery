#!/bin/bash

OUTPUTS=(
    "http_header"
    "http_setting"
    "key"
    "quic_connection_info"
    "quic_shared_config"
    "tls_certificates"
    "tls_shared_config"
)

VP="nl-ens"

for f in $(ls); do
    if [ $f == "old" ] || [ $f == "check_quic_uploads.sh" ]; then
        continue;
    fi


    alpn=$(echo $f | cut -d'_' -f3)  # h3 or doq
    TIMESTAMP=$(echo $f | cut -d'_' -f4)  # YYYYMMDD
    YEAR=$(echo ${TIMESTAMP} | cut -c1-4)
    MONTH=$(echo ${TIMESTAMP} | cut -c5-6)
    DAY=$(echo ${TIMESTAMP} | cut -c7-8)

    if [ $alpn == "h3" ]; then
        PORT="443"
    elif [ $alpn == "doq" ]; then
        PORT="853"
    fi

    for output in "${OUTPUTS[@]}"; do
        if [ $output == "key" ]; then
            EXT="log"
        else
            EXT="csv"
        fi
        #remote_etag=$(mc stat --json storage/catrin/measurements/tool=quic/dataset=udp-anycast/vp=$VP/alpn=$alpn/output=$output/port=$PORT/year=$YEAR/month=$MONTH/day=$DAY/$output.$EXT | jq -r '.etag')
        remote_etag=$(mc cat storage/catrin/measurements/tool=quic/dataset=udp-anycast/vp=$VP/alpn=$alpn/output=$output/port=$PORT/year=$YEAR/month=$MONTH/day=$DAY/$output.$EXT | md5sum | cut -d' ' -f1)
        local_etag=$(md5sum quic_v4_${alpn}_${TIMESTAMP}/$output.$EXT | cut -d' ' -f1)
        if [ "$remote_etag" != "$local_etag" ]; then
            echo "Mismatch for $f/$output, remote_etag=$remote_etag, local_etag=$local_etag"
        fi
    done

    remote_etag=$(mc stat --json storage/catrin/artefacts/tool=quic/dataset=udp-anycast/vp=$VP/alpn=$alpn/port=$PORT/year=$YEAR/month=$MONTH/day=$DAY/logs | jq -r '.etag')
    local_etag=$(md5sum quic_v4_${alpn}_${TIMESTAMP}/logs | cut -d' ' -f1)
    if [ "$remote_etag" != "$local_etag" ]; then
        echo "Mismatch for $f/log, remote_etag=$remote_etag, local_etag=$local_etag"
    fi

done
