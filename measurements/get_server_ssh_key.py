import socket
import paramiko
import argparse
import hashlib


PORT = 22  # 42512
IPS = [
    "103.17.152.152",
    "106.2.158.158",
    "106.2.159.159",
    "185.195.94.138",
    "204.10.192.1",
    "44.31.223.163",
    "45.87.220.1",
    "71.18.203.99",
    "89.37.41.104",
]


def ssh_connect_to_ip(ip, p):
    try:
        with socket.create_connection((ip, p), timeout=11) as sock:
            with paramiko.Transport(sock) as transport:
                transport.start_client(timeout=10)

                server_key = transport.get_remote_server_key()

                print(ip, server_key.fingerprint)
                print(ip, hashlib.sha256(server_key.asbytes()).hexdigest())
                # or more explicitly:
                # print(ip, server_key.get_fingerprint().hex())
                # print("Key type:", server_key.get_name())
                # print("Key bits:", server_key.get_bits())
                # print("Base64:", server_key.get_base64())

    except socket.timeout:
        print(ip, "TCP timeout")

    except TimeoutError:
        print(ip, "Connection timeout")

    except paramiko.ssh_exception.SSHException as e:
        # Often raised if SSH handshake times out or fails
        if "timed out" in str(e).lower():
            print(ip, "SSH handshake timeout")
        else:
            print(ip, "SSH error:", str(e))

    except Exception as e:
        print(ip, "Other error:", type(e).__name__, str(e))


def main(args):
    global PORT
    global IPS
    if args.ip:
        ssh_connect_to_ip(args.ip, PORT)
    else:
        for ip in IPS:
            ssh_connect_to_ip(ip, PORT)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--ip", required=False, type=str,
                        help="octet")
    main(parser.parse_args())
