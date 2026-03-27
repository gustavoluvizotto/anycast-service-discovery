import pandas as pd
from datetime import datetime
import ipaddress

# am I covering all anycast IPv4 prefixes?
vps = ["au-syd", "nl-ens"]
ts = datetime(2025, 12, 2)

_anycast_ipv4_pdf = pd.read_csv(f"../anycast_census_{ts.year}_{ts.month:02d}_{ts.day:02d}_v4.csv")
anycast_ipv4_pdf = _anycast_ipv4_pdf[_anycast_ipv4_pdf["GCD_ICMPv4"] > 1].copy()
prefixes = set(anycast_ipv4_pdf["prefix"].to_list())

for vp in vps:
    print(vp)
    nmap_pdf = pd.read_csv(f"../input/nmap/nmap_input_100ports_{vp}_tcp-anycast_v4.csv", header=None)
    nmap_pdf.columns = ["saddr"]
    ips = set(nmap_pdf["saddr"].to_list())

    missing_prefixes = []
    for prefix in prefixes:
        found = False
        prefix_n = ipaddress.IPv4Network(prefix.strip())
        for ip in ips:
            ip_n = ipaddress.IPv4Address(ip.strip())
            if ip_n in prefix_n:
                found = True
                break
        if not found:
            missing_prefixes.append(prefix)

    print("missing prefixes:", len(missing_prefixes), missing_prefixes)
