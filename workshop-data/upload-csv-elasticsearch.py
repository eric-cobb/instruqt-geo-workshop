# -*- coding: utf-8 -*-
"""
File: upload_csv_elasticsearch.py
Author: Michael Young
Date: 2024-09-01
Version: 1.1
License: BSD-3-Clause License

Description:
This python script uploads a CSV file to Elasticsearch.  It is specifically designed for
data from Trimet API where the dates are in the format of Aug 26, 2024 @ 17:05:36.032.
The Trimet data was exported from Elasticsearch.  The source data was PST, but the export
data is in EST.

Usage:
    python upload_csv_elasticsearch.py --csv data.csv --host http://localhost:9200 --password password

Arguments:
    --csv : Path to the CSV file containing data.
    --host: URL for the Elasticsearch server.
    --password: Password for Elasticsearch.

Dependencies:
    - csv
    - elasticsearch
    - hashlib
    - argparse
    - datetime
    - pytz
    - json

Example:
    python upload_csv_elasticsearch.py --csv data.csv --host http://localhost:9200 --password password

"""

import argparse
import csv
import hashlib
import os
from re import I
import sys
from datetime import datetime, timedelta, timezone
import json

from elasticsearch import Elasticsearch
from elasticsearch.helpers import streaming_bulk
from typing import Optional


def parse_arguments():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(description="Uploads a CSV file to Elasticsearch.")
    parser.add_argument("--csv", required=True, help="Path to the CSV file.")
    parser.add_argument("--host", required=True, help="Elasticsearch host URL.")
    parser.add_argument("--username", required=True, help="Elasticsearch username for the elastic user.")
    parser.add_argument("--password", required=True, help="Elasticsearch password for the elastic user.")
    parser.add_argument("--index", required=True, help="Elasticsearch index name where data will be stored.")
    parser.add_argument("--filter", required=False, default=None, help="The filter string to use for date simulation.")
    parser.add_argument("--days", required=False, type=int, default=1, help="The number of days to use for date simulation.")

    return parser.parse_args()


def validate_arguments(args):
    """Validate the provided command line arguments."""
    if not os.path.isfile(args.csv):
        print(f"Error: The file '{args.csv}' does not exist.")
        sys.exit(1)

def update_date(date: str, days: int) -> str:
    """Convert a placeholder date string in the format of '<DATE> @ 00:00:00.000' to a date string of today minus number days

    Args:
        date (str): The date string to replace.
        days (int): The number of days to subtract from the current date.
    """
    # Define the temporary date format
    date_format = "%Y-%m-%d"

    # Extract the time from the input date string.
    clean_time = date.split(" @ ", 1)[1]

    # Get the current date and time in UTC
    current_utc = datetime.now(timezone.utc)

    # Subtract the number of days from the current date
    if days is not None or days > 0:
        day_minus_utc = current_utc - timedelta(days=days) 
    else:
        day_minus_utc = current_utc

    # Convert the UTC datetime object to string format
    date_minus_utc = day_minus_utc.strftime(date_format)

    datetime_utc_str = date_minus_utc + "T" + clean_time + "Z"

    return datetime_utc_str


def generate_actions(csv_file_path, es_index, filter: Optional[str] = None, days: Optional[int] = 0):
    """
    A generator function to yield Elasticsearch actions from a CSV file.
    Replaces date values using a string match,keeping the time for better data parsing.

    Args:
        csv_file_path (str): File path for csv data.
        es_index (str): Name of Elasticsearch index.
        filter (str): Filter string to find date strings.
        days (int): Number of days to subtract from current date.
    """

    with open(csv_file_path, mode="r", encoding="utf-8") as file:
        reader = csv.DictReader(file)

        if filter:
            print(f"Using filter '{filter}' to find the date strings.")
        
        if days:
            print(f"Using {days} days for date simulation.")
        else:
            print("Using today's date for date simulation.")

        for row in reader:
            for key, value in row.items():
                # We need to replace placeholder values in keys matching filter with calculated dates.
                if filter and filter in value:
                    row[key] = update_date(value, days)

                # We need to convert the string values to boolean values.
                boolean_keys = {"trimet.inCongestion", "trimet.newTrip", "trimet.offRoute"}
                if key in boolean_keys:
                    row[key] = value.lower() == "true"

            # Add @timestamp field based on 'trimet.time' field.
            row["@timestamp"] = row["trimet.time"]

            # Convert dict to a JSON string with sorted keys for deterministic ordering
            dict_str = json.dumps(row, sort_keys=True)
    
            # Encode the string and compute the SHA256 hash
            hash_obj = hashlib.sha256(dict_str.encode("utf-8"))
    
            # Return the hex digest
            record_hash = hash_obj.hexdigest()

            # Yield an action formatted for Elasticsearch
            yield {"_index": es_index, "_id": record_hash, "_source": row}


def upload_csv_to_elasticsearch(csv_file_path, es_host, es_user, es_pass, es_index, filter: Optional[str] = None, days: Optional[int] = 0):
    """
    Upload CSV data to Elasticsearch using bulk API.
    
    Args:
        csv_file_path (str): Path to the CSV file.
        es_host (str): Elasticsearch host URL.
        es_user (str): Elasticsearch username.
        es_pass (str): Elasticsearch password.
        es_index (str): Name of Elasticsearch index where data will be stored.
        filter (str): Filter string to find date strings.
        days (int): Number of days to subtract from current date. 
    """
    try:
        # Connect to Elasticsearch
        es = Elasticsearch(es_host, basic_auth=(es_user, es_pass))

        # Check if the index exists and create if it does not exist
        if not es.indices.exists(index=es_index):
            es.indices.create(index=es_index)
        else:
            es.indices.delete(index=es_index)

        # Progress bar setup
        total_docs = sum(1 for _ in open(csv_file_path)) - 1  # Adjust for header row

        successes = 0
        try:
            for ok, action in streaming_bulk(
                client=es,
                actions=generate_actions(csv_file_path, es_index, filter, days),
                raise_on_error=False,
                raise_on_exception=False,
                chunk_size=1000,
            ):
                successes += ok

                if not ok:
                    print(action)
            print(f"Input File: {csv_file_path}, Indexed {successes}/{total_docs} documents successfully.")
        except Exception as e:
            print(f"An unexpected error occurred: {e}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")


def main():
    args = parse_arguments()
    validate_arguments(args)
    upload_csv_to_elasticsearch(args.csv, args.host, args.username, args.password, args.index, args.filter, args.days)


if __name__ == "__main__":
    # Example Usage
    #
    #python3 upload-csv-elasticsearch.py --csv data-files/33-to-clackamas-town-center.csv --host http://localhost:9200 --username elastic --password password --index trimet-geo-workshop-data --filter "<DATE>" --days 1
    #

    main()
