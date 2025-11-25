# Helper functions for anycast census data (github.com/ut-dacs/anycast-census) processing and querying
# Created by Remi Hendriks (github.com/rhendriks)

import pandas as pd
from datetime import datetime
import requests
import argparse


def download_date(year, month, day, version) -> pd.DataFrame:
    """Download and return census data for a specific date as a DataFrame.

    Args:
        year (int): The year of the data to download.
        month (int): The month of the data to download.
        day (int): The day of the data to download.
        version (str): The version of the census data ('v4' or 'v6').

    Returns:
        pd.DataFrame: DataFrame containing the census data for the specified date.
    """
    # Return error if date is before census start (2024/03/20)
    if (year, month, day) < (2024, 3, 20):
        raise ValueError("Date is before census start date of 2024-03-20")

    # Return error if date is in the future
    if datetime(year, month, day) > datetime.now():
        raise ValueError("Date is in the future")

    # URL e.g., https://github.com/ut-dacs/anycast-census/blob/main/2025/10/31/IPv4.parquet
    date_str = f"{year:04d}/{month:02d}/{day:02d}"
    url = f"https://github.com/ut-dacs/anycast-census/blob/main/{date_str}/IP{version}.parquet?raw=true"

    response = requests.get(url, timeout=60)
    if response.status_code != 200:
        raise Exception(f"Failed to download {url}: HTTP {response.status_code}")

    # Get the URL content as a bytes object
    data_bytes = response.content
    # Read the Parquet data into a DataFrame
    df = pd.read_parquet(pd.io.common.BytesIO(data_bytes))
    return df


def main(args):
    datetime_obj = datetime.strptime(args.date, "%Y%m%d")
    pdf = download_date(datetime_obj.year, datetime_obj.month, datetime_obj.day, args.version)
    output_path = args.output_dir if args.output_dir else "."
    pdf.to_csv(f"{output_path}/anycast_census_{datetime_obj.year}_{datetime_obj.month:02d}_{datetime_obj.day:02d}_{args.version}.csv", index=False)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--version", required=True, type=str,
                        help="v4 or v6")
    parser.add_argument("--date", required=True, type=str,
                        help="Download single snapshot. Format: YYYYMMDD")
    parser.add_argument("--output-dir", required=False, type=str,
                        help="Where to place the csv file. Default: current directory")
    main(parser.parse_args())
