import argparse
import json
import os
import sys

import tqdm
from elasticsearch import Elasticsearch
from elasticsearch.helpers import streaming_bulk


def parse_arguments():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="Uploads a GeoJSON file to Elasticsearch."
    )
    parser.add_argument("--json", required=True, help="Path to the GeoJSON file.")
    parser.add_argument("--host", required=True, help="Elasticsearch host URL.")
    parser.add_argument(
        "--password", required=True, help="Elasticsearch password for the elastic user."
    )

    return parser.parse_args()


def validate_arguments(args):
    """Validate the provided command line arguments."""
    if not os.path.isfile(args.json):
        print(f"Error: The file '{args.json}' does not exist.")
        sys.exit(1)


def generate_actions(geojson_file, es_index):
    """
    A generator function to yield Elasticsearch actions from a GeoJSON file.
    Replaces specific date values while keeping the time for better data parsing.

    Args:
        geojson_file (str): File path for GeoJSON data.
        es_index (str): Name of Elasticsearch index.
    """

    with open(geojson_file, mode="r", encoding="utf-8") as file:
        geojson_data = json.load(file)

        for feature in geojson_data["features"]:
            # Yield an action formatted for Elasticsearch
            yield {
                "_index": es_index,
                "_source": {
                    "state": feature["properties"].get("state"),
                    "name": feature["properties"].get("name"),
                    "cartodb_id": feature["properties"].get("cartodb_id"),
                    "created_at": feature["properties"].get("created_at"),
                    "updated_at": feature["properties"].get("updated_at"),
                    "geometry": feature["geometry"],
                },
            }


# Function to load GeoJSON from file and upload to Elasticsearch
def upload_geojson_to_elasticsearch(
    geojson_file_path, es_host, es_user, es_pass, es_index
):
    """
    Upload GeoJSON data to Elasticsearch using bulk API.

    Args:
        geojson_file_path (str): Path to the GeoJSON file.
        es_host (str): Elasticsearch host URL.
        es_pass (str): Password for Elasticsearch user.
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
        total_docs = (
            sum(1 for _ in open(geojson_file_path)) - 1
        )  # Adjust for header row
        progress = tqdm.tqdm(unit="docs", total=total_docs)

        successes = 0
        try:
            for ok, action in streaming_bulk(
                client=es,
                actions=generate_actions(geojson_file_path, es_index),
                raise_on_error=False,
                raise_on_exception=False,
                chunk_size=1000,
            ):
                progress.update(1)
                successes += ok

                if not ok:
                    print(action)
            print(f"Indexed {successes}/{total_docs} documents successfully.")
        except Exception as e:
            print(f"An unexpected error occurred: {e}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")


def main():
    es_index = "portland-geojson"
    es_user = "elastic"

    args = parse_arguments()
    validate_arguments(args)
    upload_geojson_to_elasticsearch(
        args.json, args.host, es_user, args.password, es_index
    )


if __name__ == "__main__":
    main()
