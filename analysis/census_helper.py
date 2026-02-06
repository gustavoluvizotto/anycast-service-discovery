# Helper functions for anycast census data (github.com/ut-dacs/anycast-census) processing and querying
# Created by Remi Hendriks (github.com/rhendriks)

import pandas as pd
from datetime import datetime
import requests


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