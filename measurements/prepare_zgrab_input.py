import os
import argparse

import pandas as pd

from config import ZGRAB_INPUT_DIR

zgrab_port_module_map = {
    # TLS
    5671: "amqps", # added afterwards

    443: "https",
    8443: "https",
    5989: "https",
    465: "smtps",
    990: "ftps",
    993: "imaps",
    995: "pop3s",
    992: "tls",  # 992 is telnet with TLS but zgrab2 does not support it

    # Clear text
    20: "ftp",
    21: "ftp",
    2121: "ftp",
    22: "ssh",
    23: "telnet",
    25: "smtp",
    587: "smtp",
    80: "http",
    3128: "http",
    5800: "http",
    8000: "http",
    8008: "http",
    8080: "http",
    110: "pop3",
    143: "imap",
    631: "ipp",
    3306: "mysql",
    5432: "postgres",
    1521: "oracle",
    2005: "oracle",
    20000: "dnp3",
    1723: "pptp",

    # added afterwards
    5672: "amqp",
    1911: "fox",
    11211: "memcached",
    1883: "mqtt",
    6379: "redis",
    1433: "mssql",
    445: "smb",
    27017: "mongodb",
    502: "modbus",
    102: "siemens",
    4190: "managesieve",
    47808: "bacnet",
    1080: "socks5",
}


def get_zgrab_tag(port):
    # set the trigger of services zgrab knows

    # the commented out ports are not within the top 100 nmap ports...
    #, 2381, 16993, 6789, 7443]:
    # [563, 636, 15002, 9001, 5061, 1131, 3077, 3269, 3766, 5986, 3995]:
    #, 26, 2811, 8021]:
    #, 280, 593, 16992, 6788, 4848, 777, 808, 1183, 7627, 5801, 5802, 5988, 8088]:
    #, 1186, 1862]:

    # default to banner (?)
    tag = zgrab_port_module_map.get(port, "banner")
    return tag


def prepare_zgrab_input(zmap_file: str, timestamp: str, port: int, dataset: str, vp: str) -> str:
    # create a file with saddr,domain,tag,port
    zgrab_tag = get_zgrab_tag(port)
    pdf = pd.read_json(zmap_file, lines=True)
    pdf["domain"] = ""
    pdf["tag"] = zgrab_tag
    pdf["port"] = port
    os.makedirs(ZGRAB_INPUT_DIR, exist_ok=True)
    output_file = f"{ZGRAB_INPUT_DIR}/zgrab_input_{timestamp}_{port}.csv"
    pdf[["saddr", "domain", "tag", "port"]].to_csv(output_file, index=False, header=False)
    return output_file


def main(args):
    if args.create_scan_ports:
        zgrab_ports = set({})
        with open("input/zmap/nmap_100ports", "r", encoding="utf-8") as f:
            for line in f.readlines():
                port = int(line.strip())
                zgrab_ports.add(port)
        for port in zgrab_port_module_map.keys():
            zgrab_ports.add(port)
        zgrab_ports.add(123) # NTP that is missing; for ZMap UDP scans
        with open("input/zgrab/zgrab_ports.txt", "w") as f:
            for port in list(zgrab_ports):
                f.write(f"{port}\n")
        return
    output_file = prepare_zgrab_input(args.zmap_file, args.timestamp, args.port, args.dataset, args.vp)
    print(output_file)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--timestamp", required=True, type=str, help="Timestamp in the format YYYYMMDD")
    parser.add_argument("--port", required=True, type=int, help="Port number")
    parser.add_argument("--dataset", required=True, type=str, help="Dataset name. E.g., tcp-anycast")
    parser.add_argument("--vp", required=True, type=str, help="Vantage point identifier. E.g., nl-ens")
    parser.add_argument("--zmap-file", required=True, type=str, help="ZMap output file to prepare input from")
    parser.add_argument("--create-scan-ports", action="store_true", required=False, help="Create a file with all ports to scan")
    main(parser.parse_args())
