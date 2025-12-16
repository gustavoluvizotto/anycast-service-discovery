#!/bin/bash

# artefacts
mc cp results/zgrab/zgrab_20251214090624_v4_full.log zgrab-write/catrin/artefacts/tool=zgrab/dataset=tcp-anycast/vp=nl-ens/port=top100/year=2025/month=12/day=14/zgrab_20251214090624_v4_full.log

mc cp results/zgrab/zgrab_time_20251214090624.txt zgrab-write/catrin/artefacts/tool=zgrab/dataset=tcp-anycast/vp=nl-ens/port=top100/year=2025/month=12/day=14/zgrab_time_20251214090624.txt

mc cp input/zgrab/zgrab_input_100ports_tcp-anycast_v4.csv zgrab-write/catrin/artefacts/tool=zgrab/dataset=tcp-anycast/vp=nl-ens/port=top100/year=2025/month=12/day=14/zgrab_input_100ports_tcp-anycast_v4.csv

mc cp input/zgrab/zgrab_config.ini zgrab-write/catrin/artefacts/tool=zgrab/dataset=tcp-anycast/vp=nl-ens/port=top100/year=2025/month=12/day=14/zgrab_config.ini

# measurements
mc cp results/zgrab/zgrab_20251214090624_v4.jsonl zgrab-write/catrin/measurements/tool=zgrab/dataset=tcp-anycast/format=raw/vp=nl-ens/port=top100/year=2025/month=12/day=14/zgrab_20251214090624_v4.jsonl
