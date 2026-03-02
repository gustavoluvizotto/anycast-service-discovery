import argparse

import dns.message
import dns.query
import dns.rdatatype
import dns.rdataclass
import dns.exception
import dns.resolver


PORT=53
QNAME = "version.bind"
IPS = [
    "106.2.158.158",
    "106.2.159.159",
    "111.220.2.2",
    "121.98.0.2",
    "131.203.1.5",
    "131.203.248.1",
    "149.112.127.1",
    "156.154.126.65",
    "176.52.216.22",
    "185.195.92.1",
    "185.195.94.137",
    "185.8.238.13",
    "193.119.10.10",
    "194.0.1.15",
    "194.0.2.4",
    "195.85.85.22",
    "199.184.165.2",
    "202.12.31.53",
    "203.119.42.53",
    "203.119.86.101",
    "203.119.95.53",
    "84.203.254.34",
    "84.203.255.34",
    "89.106.200.53",
]


def dns_query_txt_chaos(ip, p):
    global QNAME

    query = dns.message.make_query(
        QNAME,
        dns.rdatatype.TXT,
        dns.rdataclass.CH
    )
    txt = ""
    try:
        response = dns.query.udp(query, ip, port=p, timeout=3)

        rcode = response.rcode()
        if rcode != 0:
            print(ip, f"[ERROR] RCODE={dns.rcode.to_text(rcode)}")
        elif not response.answer:
            print(ip, "[INFO] No answer section")
        else:
            for answer in response.answer:
                for item in answer.items:
                    txt += item.to_text().strip('"')
            print(ip, txt)

    except dns.exception.Timeout:
        print(ip, "[TIMEOUT] Server did not respond")

    except dns.resolver.NXDOMAIN:
        print(ip, "[NXDOMAIN] Domain does not exist")

    except dns.resolver.NoNameservers as e:
        print(ip, f"[NO NAMESERVERS] {e}")

    except dns.query.BadResponse:
        print(ip, "[BAD RESPONSE] Malformed or unexpected reply")

    except Exception as e:
        print(ip, f"[GENERIC ERROR] {type(e).__name__}: {e}")


def main(args):
    global PORT
    global IPS
    if args.ip:
        dns_query_txt_chaos(args.ip, PORT)
    else:
        for ip in IPS:
            dns_query_txt_chaos(ip, PORT)



if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--ip", required=False, type=str,
                        help="octet")
    main(parser.parse_args())
