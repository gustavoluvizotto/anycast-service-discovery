# Helper function to add ASN data
import requests
from bs4 import BeautifulSoup
import radix
import gzip
import pandas as pd
from datetime import datetime
from typing import Tuple, Optional
from tqdm.auto import tqdm

class CaidaASLookup:
    def __init__(self, date_obj: datetime):
        """
        Initialize prefix2as for a given date
        Data is downloaded (and radix is created) when the first lookup is performed.

        :param date_obj: datetime object representing the day of data to fetch.
        """
        self.ts = date_obj
        self.radix_v4: Optional[radix.Radix] = None
        self.radix_v6: Optional[radix.Radix] = None

        # URL Templates
        self.base_url_v4 = f"https://data.caida.org/datasets/routing/routeviews-prefix2as/{self.ts.year}/{self.ts.month:02d}"
        self.base_url_v6 = f"https://data.caida.org/datasets/routing/routeviews6-prefix2as/{self.ts.year}/{self.ts.month:02d}"

    def _get_day_url(self, is_ipv4: bool) -> str:
        """Finds the specific .gz file URL for the initialized date."""
        base_url = self.base_url_v4 if is_ipv4 else self.base_url_v6
        daymask = f'{self.ts.year}{self.ts.month:02d}{self.ts.day:02d}'

        try:
            response = requests.get(base_url, timeout=15)
            response.raise_for_status()

            soup = BeautifulSoup(response.text, 'html.parser')
            for node in soup.find_all('a'):
                href = node.get('href')
                if href and href.endswith('pfx2as.gz') and daymask in href:
                    return f"{base_url}/{href}"

        except requests.exceptions.RequestException as e:
            raise RuntimeError(f"Error connecting to CAIDA directory {base_url}: {e}")

        raise FileNotFoundError(f"Unable to find CAIDA data for date {daymask} at {base_url}")

    def _build_radix_tree(self, is_ipv4: bool) -> radix.Radix:
        """Downloads data and builds a Radix tree."""
        url = self._get_day_url(is_ipv4)
        rtree = radix.Radix()

        print(f"Downloading and parsing {'IPv4' if is_ipv4 else 'IPv6'} data from {url}...")

        try:
            # Stream the download so we don't load the compressed file entirely into RAM before unzipping
            with requests.get(url, stream=True, timeout=30) as r:
                r.raise_for_status()
                # Use gzip on the raw stream
                with gzip.GzipFile(fileobj=r.raw) as f:
                    count = 0
                    for line in f:
                        line = line.decode('utf-8').strip()
                        if not line: continue

                        parts = line.split('\t')
                        if len(parts) != 3:
                            continue

                        # CAIDA format: prefix \t length \t asn
                        # Radix expects CIDR format: prefix/length
                        network = f"{parts[0]}/{parts[1]}"
                        asn = parts[2]

                        node = rtree.add(network)
                        node.data["AS"] = asn
                        node.data["prefix"] = network

                        count += 1
                        if count % 100000 == 0:
                            print('.', end='', flush=True)

            print(" Done.")
            print(f"Processed {count} prefixes.")
            return rtree

        except Exception as e:
            raise RuntimeError(f"Failed to build Radix tree from {url}: {e}")

    def _get_tree(self, is_ipv4: bool) -> radix.Radix:
        """Retrieves the cached tree or builds it if missing."""
        if is_ipv4:
            if self.radix_v4 is None:
                self.radix_v4 = self._build_radix_tree(True)
            return self.radix_v4
        else:
            if self.radix_v6 is None:
                self.radix_v6 = self._build_radix_tree(False)
            return self.radix_v6

    def _lookup_ip(self, ip: str, rtree: radix.Radix) -> Tuple[str, str]:
        """Helper to look up a single IP."""
        try:
            rnode = rtree.search_best(ip)
            if rnode:
                return rnode.data.get('prefix', '-'), rnode.data.get('AS', '-')
        except Exception:
            # Handles malformed IPs gracefully
            pass
        return '-', '-'

    def add_prefix_and_asn(
            self,
            df: pd.DataFrame,
            addr_col: str,
            ip_version: str = 'v4',
            asn_col: str = 'ASN',
    ) -> pd.DataFrame:
        """
        Enriches the dataframe with 'bgp_prefix' and 'ASN'.

        :param df: The pandas DataFrame.
        :param addr_col: The name of the column containing IP addresses.
        :param ip_version: 'v4' or 'v6'.
        :return: The DataFrame with new columns.
        """
        if ip_version not in ['v4', 'v6']:
            raise ValueError("ip_version must be 'v4' or 'v6'")

        is_ipv4 = (ip_version == 'v4')
        rtree = self._get_tree(is_ipv4)

        print(f"Mapping {len(df)} IPs against {ip_version.upper()} tree...")

        # perform lookup
        results = [
            self._lookup_ip(ip, rtree)
            for ip in tqdm(df[addr_col], total=df.shape[0], desc="ASN Lookup")
        ]
        # add results to dataframe
        df['bgp_prefix'], df[asn_col] = zip(*results)

        return df
