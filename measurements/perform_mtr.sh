#!/bin/bash

# distribute this script at all VPs
# ./perform_mtr.sh <source_ip> <target_ip> [protocol]
# example: ./perform_mtr.sh 45.32.233.199 1.1.1.1 icmp

# --- Configuration ---
# Number of packets to send for each hop

PACKET_COUNT=1
# --- End Configuration ---


# --- Argument Validation ---
# Check if a source and target IP address was provided as the first argument.
if [[ -z "$1" && -z "$2" ]]; then
  echo "Error: No source and target IP address specified."
  echo "Usage: $0 <source_ip> <target_ip> [protocol]"
  echo "       protocol can be 'icmp', 'tcp', or 'udp'. Default is 'icmp'."
  exit 1
fi

# Assign 
SOURCE_IP="$1"
# Assign command-line arguments to variables.
TARGET_IP="$2"
# Assign the second argument to PROTOCOL. If it's not provided, default to "icmp".
PROTOCOL="${3:-icmp}"


# --- Initialization ---
# Get the hostname of the machine running the script
SOURCE_HOSTNAME=$(hostname)
OUTPUT_FILE="results/mtr/mtr_${TARGET_IP}.json"

# Determine the correct MTR flag based on the PROTOCOL variable and validate it.
MTR_PROTOCOL_FLAG=""
case "$PROTOCOL" in
    icmp) # No flag is needed for ICMP, it's the default.
        ;;
    tcp)
        MTR_PROTOCOL_FLAG="--tcp"
        ;;
    udp)
        MTR_PROTOCOL_FLAG="--udp"
        ;;
    *)
        echo "Error: Invalid protocol '$PROTOCOL'."
        echo "Please use 'icmp', 'tcp', or 'udp'."
        exit 1
        ;;
esac

echo "Creating new results file: $OUTPUT_FILE"
# Mtr_Version,Start_Time,Status,Host,Hop,Ip,Asn,Loss%,Snt, ,Last,Avg,Best,Wrst,StDev,
echo "hostname,Src,Mtr_Version,Start_Time,Status,Host,Hop,Ip,Asn,Loss%,Snt, ,Last,Avg,Best,Wrst,StDev" > "$OUTPUT_FILE"


# --- Main Execution ---
echo "Running MTR for target: $TARGET_IP using protocol: $PROTOCOL"

# Run MTR
mtr -b -z $MTR_PROTOCOL_FLAG --report --json -c "$PACKET_COUNT" "$TARGET_IP" >> 
#mtr -b -z $MTR_PROTOCOL_FLAG --report --csv -c "$PACKET_COUNT" "$TARGET_IP" | \
#  tail -n +2 | \
#  awk -v hostname="$SOURCE_HOSTNAME" -v src="$SOURCE_IP" 'BEGIN{FS=OFS=","} {print hostname, src, $0}' >> "$OUTPUT_FILE"

echo "--------------------------------------------------"
echo "MTR data collection complete for $TARGET_IP."
