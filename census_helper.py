# Helper functions for anycast census data (github.com/ut-dacs/anycast-census) processing and querying
# Created by Remi Hendriks (github.com/rhendriks)

import pandas as pd
from datetime import datetime
import requests
import argparse


"""
# example
import census_helper
from datetime import datetime

ts = datetime(2026, 2, 3)

census = census_helper.download_date(ts.year, ts.month, ts.day, ts.version)
census.head()
"""
def download_date(date_obj: datetime, version) -> pd.DataFrame:
    """Download and return census data for a specific date as a DataFrame.

    Args:
        date_obj (datetime): datetime object representing the day of data to fetch.

        version (str): The version of the census data ('v4' or 'v6').

    Returns:
        pd.DataFrame: DataFrame containing the census data for the specified date.
    """
    # Return error if date is before census start (2024/03/20)
    if (date_obj.year, date_obj.month, date_obj.day) < (2024, 3, 20):
        raise ValueError("Date is before census start date of 2024-03-20")

    # Return error if date is in the future
    if datetime(date_obj.year, date_obj.month, date_obj.day) > datetime.now():
        raise ValueError("Date is in the future")

    # URL e.g., https://github.com/ut-dacs/anycast-census/blob/main/2025/10/31/IPv4.parquet
    date_str = f"{date_obj.year:04d}/{date_obj.month:02d}/{date_obj.day:02d}"
    url = f"https://github.com/ut-dacs/anycast-census/blob/main/{date_str}/IP{version}.parquet?raw=true"

    response = requests.get(url)
    if response.status_code != 200:
        raise Exception(f"Failed to download {url}: HTTP {response.status_code}")

    # Get the URL content as a bytes object
    data_bytes = response.content
    # Read the Parquet data into a DataFrame
    df = pd.read_parquet(pd.io.common.BytesIO(data_bytes))
    return df


def store_prefixes_only(ts, anycast_pdf, version, output_path):
    gcd_col = "GCD_ICMPv4"
    if version == "v6":
        gcd_col = "GCD_ICMPv6"
    anycast_pdf[anycast_pdf[gcd_col] > 1]["prefix"].to_csv(f"{output_path}/anycast_prefixes_{ts.year}_{ts.month:02d}_{ts.day:02d}_{version}.csv", index=False, header=False)


def main(args):
    datetime_obj = datetime.strptime(args.date, "%Y%m%d")
    pdf = download_date(datetime_obj.year, datetime_obj.month, datetime_obj.day, args.ip_version)
    output_path = args.output_dir if args.output_dir else "."
    if args.prefixes_only:
        store_prefixes_only(datetime_obj, pdf, args.ip_version, output_path)
    else:
        pdf.to_csv(f"{output_path}/anycast_census_{datetime_obj.year}_{datetime_obj.month:02d}_{datetime_obj.day:02d}_{args.ip_version}.csv", index=False)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--ip-version", required=True, type=str,
                        help="v4 or v6")
    parser.add_argument("--date", required=True, type=str,
                        help="Download single snapshot. Format: YYYYMMDD")
    parser.add_argument("--output-dir", required=False, type=str,
                        help="Where to place the csv file. Default: current directory")
    parser.add_argument("--prefixes-only", action="store_true", required=False,
                        help="Store a file with only the anycast prefixes with GCD>1 (accurate)")
    main(parser.parse_args())
