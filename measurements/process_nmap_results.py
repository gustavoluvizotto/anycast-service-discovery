import pandas as pd
import xml.etree.ElementTree as ET
from libnmap.parser import NmapParser
import os

xml_files = [
        "results/nmap/nmap_20251216201453__10_of_30.csv_.xml",
        "results/nmap/nmap_20251216201453__15_of_30.csv_.xml",
        "results/nmap/nmap_20251216201453__1_of_30.csv_.xml",
        "results/nmap/nmap_20251216201453__24_of_30.csv_.xml",
        "results/nmap/nmap_20251216201453__29_of_30.csv_.xml",
        "results/nmap/nmap_20251216201453__5_of_30.csv_.xml",
        "results/nmap/nmap_20251216201453__11_of_30.csv_.xml",
        "results/nmap/nmap_20251216201453__16_of_30.csv_.xml",
        "results/nmap/nmap_20251216201453__20_of_30.csv_.xml",
        "results/nmap/nmap_20251216201453__25_of_30.csv_.xml",
        "results/nmap/nmap_20251216201453__2_of_30.csv_.xml",
        "results/nmap/nmap_20251216201453__6_of_30.csv_.xml",
        "results/nmap/nmap_20251216201453__12_of_30.csv_.xml",
        "results/nmap/nmap_20251216201453__17_of_30.csv_.xml",
        "results/nmap/nmap_20251216201453__21_of_30.csv_.xml",
        "results/nmap/nmap_20251216201453__26_of_30.csv_.xml",
        "results/nmap/nmap_20251216201453__30_of_30.csv_.xml",
        "results/nmap/nmap_20251216201453__7_of_30.csv_.xml",
        "results/nmap/nmap_20251216201453__13_of_30.csv_.xml",
        "results/nmap/nmap_20251216201453__18_of_30.csv_.xml",
        "results/nmap/nmap_20251216201453__22_of_30.csv_.xml",
        "results/nmap/nmap_20251216201453__27_of_30.csv_.xml",
        "results/nmap/nmap_20251216201453__3_of_30.csv_.xml",
        "results/nmap/nmap_20251216201453__8_of_30.csv_.xml",
        "results/nmap/nmap_20251216201453__14_of_30.csv_.xml",
        "results/nmap/nmap_20251216201453__19_of_30.csv_.xml",
        "results/nmap/nmap_20251216201453__23_of_30.csv_.xml",
        "results/nmap/nmap_20251216201453__28_of_30.csv_.xml",
        "results/nmap/nmap_20251216201453__4_of_30.csv_.xml",
        "results/nmap/nmap_20251216201453__9_of_30.csv_.xml"
]

rows = []  # collect rows here
scan_time = 0
for xml_file in xml_files:
    print(f"Processing {xml_file}...")

    # parse rtt for each host
    try:
        tree = ET.parse(xml_file)
    except ET.ParseError as e:
        print(f"Error parsing {xml_file}: {e}")
        continue
    root = tree.getroot()
    
    host_rtts = {}
    cnt = 0
    if root.find("runstats") is None:
        scan_time += 0
    else:
        scan_time += float(root.find("runstats").find("finished").get("elapsed"))
    for host in root.findall("host"):
        addr_el = host.find("address")
        ip = addr_el.get("addr") if addr_el is not None else None

        times = host.find("times")
        if times is not None:
            srtt = int(times.get("srtt")) / 1e6   # convert to s
            host_rtts[ip] = srtt
            cnt += 1

    #print("amount of srtt found:", cnt)
    report = NmapParser.parse_fromfile(xml_file)
    filename = os.path.splitext(os.path.basename(xml_file))[0]
    print("xml parsed. Extracting fields...")

    scan_ts = pd.to_datetime(filename.split("_")[1], utc=True)
    for host in report.hosts:
        for svc in host.services:
            rows.append(
            {
                "host": host.address,
                "rtt_ms": host_rtts.get(host.address),
                "port": svc.port,
                "protocol": svc.protocol,
                "service": svc.service,
                "os": host.os,
                "banner": svc.banner,
                "scan_timestamp": scan_ts,
            })
            #nmap_pdf = pd.concat([nmap_pdf, row], ignore_index=True)
    uniq_hosts_w_services = set([host.address for host in report.hosts if len(host.services) > 0])
    uniq_hosts = set([host.address for host in report.hosts])
    print("file", xml_file, "uniq hosts", len(uniq_hosts), "hosts with services", len(uniq_hosts_w_services))


nmap_expanded_pdf = pd.DataFrame(rows, columns=["host", "rtt_ms", "port", "protocol",
                                       "service", "os", "banner", "scan_timestamp"])
#nmap_expanded_pdf.to_csv("../results/nmap/production_sharded_scans/nmap_combined_production_sharded_scans.csv", index=False)
print("Processed files:", len(xml_files))
print("Total scan time if not sharded:", scan_time/3600, "hours")
print("Average scan time per file:", scan_time / len(xml_files) / 3600, "hours")
print("hosts with service", nmap_expanded_pdf["host"].nunique())


cols_to_list = ["protocol", "service", "os", "banner", "port"]
nmap_pdf = nmap_expanded_pdf.groupby(["host", "rtt_ms", "scan_timestamp"], dropna=False).agg({col: list for col in cols_to_list}).reset_index()

print(nmap_pdf)

print("hosts with service", nmap_pdf["host"].nunique())

nmap_pdf["unique_services"] = nmap_pdf["service"].apply(lambda x: set(x))
print(nmap_pdf.explode("unique_services").groupby("unique_services").size().reset_index(name="counts").sort_values(by="counts", ascending=False))

ports = set(nmap_pdf.explode("port")["port"].to_list())
print("unique ports scanned:", len(ports))


nmap_expanded_pdf.to_csv("results/nmap/nmap_20251216201453__.csv", index=False)
