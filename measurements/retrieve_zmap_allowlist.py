#!/usr/bin/env python3
"""
Inspired from
https://github.com/gustavoluvizotto/goscanner-container/blob/main/retrieve_allowlist.py
"""
__author__ = "Gustavo Luvizotto Cesar"
__email__ = "g.luvizottocesar@utwente.nl"

import argparse
from datetime import datetime
import os

#from storage_path import AllowlistStoragePath
from objstore import ObjStore

from config import ALLOWLIST_DIR, OBJSTORE_ZMAP_BASEDIR


def main(args):
    retrieve_allowlist(args.timestamp, args.port, args.dataset, args.vp)


def retrieve_allowlist(timestamp: str, port: int, dataset: str, vp: str) -> None:
    #prefix = AllowlistStoragePath.get_prefix(port)
    catrin = ObjStore("catrin")
    catrin_bucket = catrin.get_bucket()

    zmap_measurements = []
    prefix = OBJSTORE_ZMAP_BASEDIR.format(dataset=dataset, vp=vp, port=port) + "/"
    for obj in catrin_bucket.objects.filter(Prefix=prefix):
        zmap_measurements.append(obj.key)
    zmap_measurements.sort(reverse=True)
    allowlist = _get_latest_measurement(timestamp, zmap_measurements)
    subpath = allowlist.split('tool=zmap/')[-1]
    target = os.path.join(ALLOWLIST_DIR, subpath)
    subdir = os.path.dirname(target)
    os.makedirs(subdir, exist_ok=True)
    catrin.download(allowlist, target)


def _get_latest_measurement(timestamp, zmap_measurements):
    # zmap_measurements list has to be sorted!
    found_file = None
    for meas_path in zmap_measurements:
        filename = os.path.basename(meas_path)
        actual_date_str = os.path.splitext(filename)[0].split("_")[-1]
        dat_file_date = datetime.strptime(actual_date_str, "%Y%m%d%H%M%S")
        # discard hours, minutes and seconds to have a fair comparison
        dat_file_date = dat_file_date.replace(hour=0, minute=0, second=0)

        desired_date = datetime.strptime(timestamp, "%Y%m%d")
        if dat_file_date <= desired_date:
            found_file = meas_path
            break
    assert (
        found_file is not None
    ), "Could not find the closest file you were looking for"
    return found_file


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--timestamp", required=True, type=str, help="Timestamp in the format YYYYMMDD")
    parser.add_argument("--port", required=True, type=int, help="Port number")
    parser.add_argument("--dataset", required=True, type=str, help="Dataset name. E.g., tcp-anycast")
    parser.add_argument("--vp", required=True, type=str, help="Vantage point identifier. E.g., nl-ens")
    main(parser.parse_args())
