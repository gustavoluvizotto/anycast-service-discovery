#!/bin/bash

IFACE=$1
INTERVAL=30  # X seconds of interval
OUTFILE="bandwidth_${IFACE}.csv"

echo "timestamp,rx_bytes,tx_bytes,rx_packets,tx_packets,rx_dropped,tx_dropped" > $OUTFILE

while true; do
    TS=$(date +%s)
    RX=$(cat /sys/class/net/$IFACE/statistics/rx_bytes)
    TX=$(cat /sys/class/net/$IFACE/statistics/tx_bytes)
    RX_PACKETS=$(cat /sys/class/net/$IFACE/statistics/rx_packets)
    TX_PACKETS=$(cat /sys/class/net/$IFACE/statistics/tx_packets)
    RX_DROPPED=$(cat /sys/class/net/$IFACE/statistics/rx_dropped)
    TX_DROPPED=$(cat /sys/class/net/$IFACE/statistics/tx_dropped)

    echo "$TS,$RX,$TX,$RX_PACKETS,$TX_PACKETS,$RX_DROPPED,$TX_DROPPED" >> $OUTFILE
    sleep $INTERVAL
done
