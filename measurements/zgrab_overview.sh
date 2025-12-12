#!/bin/bash
#

zgrab_file=$1

echo "==================STATUS OVERVIEW================"
jq -r '
  . as $root
  | ($root.data | keys[0]) as $proto
  | [$proto, $root.data[$proto].status]
  | @tsv
' $zgrab_file | sort | uniq -c

echo "=======================RESULT OVERVIEW=============="
jq -r '
  . as $root
  | ($root.data | keys[0]) as $proto
  | select($proto != "http" and $proto != "https")
  | $root.data[$proto]
  | select(.status == "success")
  | [$proto, (.result | @json)]
  | @tsv
' $zgrab_file \
| sort | uniq -c | sort -rn | head -10
