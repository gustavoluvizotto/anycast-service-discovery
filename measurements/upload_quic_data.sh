#!/bin/bash

mc cp results/quic/quic_v4_doq_20251213153809/logs quic-write/catrin/artefacts/tool=quic/dataset=anycast-v4/vp=au-syd/alpn=doq/port=853/year=2025/month=12/day=13/logs

mc cp results/quic/quic_v4_doq_20251213153809/http_header.csv quic-write/catrin/measurements/tool=quic/dataset=anycast-v4/vp=au-syd/alpn=doq/port=853/year=2025/month=12/day=13/http_header.csv

mc cp results/quic/quic_v4_doq_20251213153809/http_setting.csv quic-write/catrin/measurements/tool=quic/dataset=anycast-v4/vp=au-syd/alpn=doq/port=853/year=2025/month=12/day=13/http_setting.csv

mc cp results/quic/quic_v4_doq_20251213153809/key.log quic-write/catrin/measurements/tool=quic/dataset=anycast-v4/vp=au-syd/alpn=doq/port=853/year=2025/month=12/day=13/key.log

mc cp results/quic/quic_v4_doq_20251213153809/quic_connection_info.csv quic-write/catrin/measurements/tool=quic/dataset=anycast-v4/vp=au-syd/alpn=doq/port=853/year=2025/month=12/day=13/quic_connection_info.csv

mc cp results/quic/quic_v4_doq_20251213153809/quic_shared_config.csv quic-write/catrin/measurements/tool=quic/dataset=anycast-v4/vp=au-syd/alpn=doq/port=853/year=2025/month=12/day=13/quic_shared_config.csv

mc cp results/quic/quic_v4_doq_20251213153809/tls_certificates.csv quic-write/catrin/measurements/tool=quic/dataset=anycast-v4/vp=au-syd/alpn=doq/port=853/year=2025/month=12/day=13/tls_certificates.csv

mc cp results/quic/quic_v4_doq_20251213153809/tls_shared_config.csv quic-write/catrin/measurements/tool=quic/dataset=anycast-v4/vp=au-syd/alpn=doq/port=853/year=2025/month=12/day=13/tls_shared_config.csv