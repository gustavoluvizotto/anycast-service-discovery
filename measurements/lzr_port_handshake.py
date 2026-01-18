
import argparse
# https://lizizhikevich.github.io/assets/papers/lzr.pdf

LZR_ALL_HS = [
    "amqp","bgp","dnp3","dns","fox","ftp","http","imap","ipmi","ipp",
    "kubernetes","memcached_ascii","memcached_binary","modbus","mongodb","mqtt",
    "mssql","mysql","newlines","newlines50","oracle","pop3","postgres","pptp",
    "rdp","redis","rtsp","siemens","smb","smtp","ssh","telnet","tls","vnc",
    "wait","x11"
]
# table 2 (best results for scanning order)
IANA_HS = [
    "wait","tls","http","dns","pptp"
]
EPHEMERAL_HS = [
    "wait","http","tls","oracle","pptp"
]
lzr_port_hs_map = {
    # commented ports are not on top100 nmap ports and are redundant with other hs
    5671: ["wait", "tls", "amqp"],
    5672: ["wait", "amqp"],
    179: ["wait", "bgp"],
    1911: ["wait", "fox"],
    623: ["wait", "ipmi"],  # https://www.speedguide.net/port.php?port=623
    6443: ["wait", "tls", "kubernetes"],
    11211: ["wait", "memcached_ascii", "memcached_binary"],
    3389: ["wait", "rdp"],
    1883: ["wait", "mqtt"],
    6379: ["wait", "redis"],
    5900: ["wait", "vnc"],
    1433: ["wait", "mssql"],
    445: ["wait", "smb"],
    27017: ["wait", "mongodb"],
    502: ["wait", "modbus"],
    102: ["wait", "siemens"],
    322: ["wait", "tls", "rtsp"],
    554: ["wait", "rtsp"],
    #8554: ["wait", "rtsp"],
    6000: ["wait", "x11"],

    443: ["wait", "tls", "http"],
    8443: ["wait", "tls", "http"],
    #2381: ["wait", "tls", "http"],
    #16993: ["wait", "tls", "http"],
    #6789: ["wait", "tls", "http"],
    #7443: ["wait", "tls", "http"],
    5989: ["wait", "tls", "http"],

    465: ["wait", "tls", "smtp"],
    990: ["wait", "tls", "ftp"],
    993: ["wait", "tls", "imap"],
    995: ["wait", "tls", "pop3"],

    20: ["wait", "ftp"],
    21: ["wait", "ftp"],
    2121: ["wait", "ftp"],
    #2811: ["wait", "ftp"],
    #8021: ["wait", "ftp"],

    22: ["wait", "ssh"],
    23: ["wait", "telnet"],
    992: ["wait", "tls", "telnet"],
    25: ["wait", "smtp"],
    587: ["wait", "smtp"],
    53: ["wait", "dns"],

    80: ["wait", "http"],
    #280: ["wait", "http"],
    #593: ["wait", "http"],
    #16992: ["wait", "http"],
    #6788: ["wait", "http"],
    #4848: ["wait", "http"],
    #777: ["wait", "http"],
    #808: ["wait", "http"],
    #1183: ["wait", "http"],
    3128: ["wait", "http"],
    #7627: ["wait", "http"],
    5800: ["wait", "http"],
    #5801: ["wait", "http"],
    #5802: ["wait", "http"],
    8000: ["wait", "http"],
    8008: ["wait", "http"],
    #5988: ["wait", "http"],
    8080: ["wait", "http"],
    #8088: ["wait", "http"],

    110: ["wait", "pop3"],
    143: ["wait", "imap"],
    631: ["wait", "ipp"],

    #1186: ["wait", "mysql"],
    3306: ["wait", "mysql"],
    #1862: ["wait", "mysql"],

    5432: ["wait", "postgres"],
    1521: ["wait", "oracle"],
    2005: ["wait", "oracle"],
    20000: ["wait", "dnp3"],
    1723: ["wait", "pptp"],
}
# https://en.wikipedia.org/wiki/Ephemeral_port
EPHEMERAL_START = 49152 # until 65535


def get_missing_handshakes(handshake_list, is_ephemeral):
    global LZR_ALL_HS
    exclude_set = {
        "wait",  # this is given
        "newlines50",  # "when sending 50 newline characters... causes the lack of responses." (see LZR paper)
    }
    hs_set = set(handshake_list)

    if is_ephemeral:
        for hs in EPHEMERAL_HS:
            if hs not in hs_set and hs not in exclude_set:
                hs_set.add(hs)
                handshake_list.append(hs)  # add order to do hs
    else:
        for hs in IANA_HS:
            if hs not in hs_set and hs not in exclude_set:
                hs_set.add(hs)
                handshake_list.append(hs)  # add order to do hs

    # include newlines hs right after...
    if "newlines" not in hs_set:
        hs_set.add("newlines")
        handshake_list.append("newlines")

    all_hs_set = set(LZR_ALL_HS) - exclude_set
    missing_set = all_hs_set - hs_set

    # just try hs of everything else then...
    for hs in missing_set:
        handshake_list.append(hs)

    return handshake_list


def main(args):
    if args.print_ports:
        for port in sorted(lzr_port_hs_map.keys()):
            print(port)
        return
    if args.create_scan_ports:
        lzr_ports = set({})
        with open("measurements/input/zmap/nmap_100ports", "r", encoding="utf-8") as f:
            for line in f.readlines():
                port = int(line.strip())
                lzr_ports.add(port)
        for port in lzr_port_hs_map.keys():
            lzr_ports.add(port)
        with open("measurements/input/lzr/lzr_ports.txt", "w") as f:
            for port in list(lzr_ports):
                f.write(f"{port}\n")
        return
    hs = lzr_port_hs_map.get(args.port, None)
    if hs:
        all_hs = get_missing_handshakes(hs, is_ephemeral=False)
    elif args.port >= EPHEMERAL_START:  # ephemeral port
        all_hs = get_missing_handshakes(EPHEMERAL_HS, is_ephemeral=True)
    else:
        all_hs = get_missing_handshakes(IANA_HS, is_ephemeral=False)

    print(','.join([hs for hs in all_hs]))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="LZR Port Handshake Mapper")
    parser.add_argument("--port", type=int, required=False,
                        help="Port number to get handshake sequence for")
    parser.add_argument("--print-ports", action="store_true", required=False,
                        help="Print all ports in the mapping")
    parser.add_argument("--create-scan-ports", action="store_true", required=False,
                        help="Create a file with all ports to scan")
    args = parser.parse_args()
    main(args)
