#!/bin/bash

# TEST SCANS:

# using input file
#docker compose run --rm -T --interactive lzr --handshakes http -sendSYNs -sourceIP 145.90.8.11 -sendInterface ens2f0np0 -gatewayMac 5c:6f:69:74:ca:60 -f results/lzr/test.json -rate 500 < input/lzr/lzr_sample_20251202.csv

# reusing zmap results
docker compose run --rm -T --interactive zmap -B 30M -p 80 -w input/zmap/head.csv --source-ip=145.90.8.11 -f "saddr,daddr,sport,dport,seqnum,acknum,window" -O json --output-filter="success=1 && repeat=0" | docker compose run --rm -T --interactive lzr --handshakes http -sendInterface ens2f0np0 -gatewayMac 5c:6f:69:74:ca:60 -f results/lzr/test.json -rate 500

