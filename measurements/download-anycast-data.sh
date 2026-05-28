#!/bin/bash

alias="tmp_rw"  # no more catrin-measurements
declare -a vps=(
"au-syd"
"nl-ens"
"de-mun"
)

#################
# download zmap #
#################
declare -a PORTS=()
while IFS= read -r line; do
    PORTS+=("$line")
done < "lzr_ports.txt"
declare -a datasets=(
"tcp-anycast"
"udp-anycast"
)

tool="zmap"
for dataset in "${datasets[@]}"; do
    for vp in "${vps[@]}"; do
        while IFS= read -r line; do
            timestamp="$line"  # each line, date in format YYYYMMDD
            year=${timestamp:0:4}
            month=${timestamp:4:2}
            day=${timestamp:6:2}
            month_clean=$((10#$month))
            day_clean=$((10#$day))
            for port in "${PORTS[@]}"; do
                mkdir -p "catrin/measurements/tool=${tool}/dataset=${dataset}/vp=${vp}/port=${port}/year=${year}/month=${month}/day=${day}/"
                mc cp -r --no-color --dp ${alias}/luvizottocesarg-tmp/anycast-service-discovery/catrin/measurements/tool=${tool}/dataset=${dataset}/vp=${vp}/port=${port}/year=${year}/month=${month_clean}/day=${day_clean}/ catrin/measurements/tool=${tool}/dataset=${dataset}/vp=${vp}/port=${port}/year=${year}/month=${month}/day=${day}/
            done
        done < "${vp}-dates.txt"
    done
done
exit

#################
# download zgrab#
#################
declare -a PORTS=(
"all_ports"
"ssh_ports"
"email_ports"
)

tool="zgrab"
dataset="tcp-anycast"
for vp in "${vps[@]}"; do
    while IFS= read -r line; do
        timestamp="$line"  # each line, date in format YYYYMMDD
        year=${timestamp:0:4}
        month=${timestamp:4:2}
        day=${timestamp:6:2}
        month_clean=$((10#$month))
        day_clean=$((10#$day))
        for port in "${PORTS[@]}"; do
            mkdir -p "catrin/measurements/tool=${tool}/dataset=${dataset}/format=parquet/vp=${vp}/port=${port}/year=${year}/month=${month}/day=${day}/"
            mc cp -r --no-color --dp ${alias}/luvizottocesarg-tmp/anycast-service-discovery/catrin/measurements/tool=${tool}/dataset=${dataset}/format=parquet/vp=${vp}/port=${port}/year=${year}/month=${month_clean}/day=${day_clean}/ \
            catrin/measurements/tool=${tool}/dataset=${dataset}/format=parquet/vp=${vp}/port=${port}/year=${year}/month=${month}/day=${day}/
        done
    done < "${vp}-dates.txt"
done

##################
## download lzr  #
##################
declare -a PORTS=()
while IFS= read -r line; do
    PORTS+=("$line")
done < "lzr_ports.txt"
dataset="tcp-anycast"

tool="lzr"
for vp in "${vps[@]}"; do
    while IFS= read -r line; do
        timestamp="$line"  # each line, date in format YYYYMMDD
        year=${timestamp:0:4}
        month=${timestamp:4:2}
        day=${timestamp:6:2}
        month_clean=$((10#$month))
        day_clean=$((10#$day))
        for port in "${PORTS[@]}"; do
            mkdir -p "catrin/measurements/tool=${tool}/dataset=${dataset}/format=parquet/vp=${vp}/port=${port}/year=${year}/month=${month}/day=${day}"
            mc cp -r --no-color --dp ${alias}/luvizottocesarg-tmp/anycast-service-discovery/catrin/measurements/tool=${tool}/dataset=${dataset}/format=parquet_minimal/vp=${vp}/port=${port}/year=${year}/month=${month_clean}/day=${day_clean}/ \
            catrin/measurements/tool=${tool}/dataset=${dataset}/format=parquet/vp=${vp}/port=${port}/year=${year}/month=${month}/day=${day}/
        done
    done < "${vp}-dates.txt"
done

# zip everything:
# https://www.cyberciti.biz/faq/compress-the-whole-directory-using-xz-and-tar/
#tar -cf - catrin/ | xz -9ze -T0 > anycast-services.tar.xz
