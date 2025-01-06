#!/bin/bash 
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd ${SCRIPT_DIR}

# Function to retry a command with exponential backoff
retry_command() {
    local max_attempts=8
    local timeout=1
    local attempt=1
    local exit_code=0

    while [ $attempt -le $max_attempts ]
    do
        "$@"
        exit_code=$?

        if [ $exit_code -eq 0 ]; then
            break
        fi

        echo "Attempt $attempt failed! Retrying in $timeout seconds..."
        sleep $timeout
        attempt=$(( attempt + 1 ))
        timeout=$(( timeout * 2 ))
    done

    if [ $exit_code -ne 0 ]; then
        echo "Command $@ failed after $attempt attempts!"
    fi

    return $exit_code
}

# Function to report status messages reducing duplication of echo commands
report_status()
{
    echo ""
    echo "$@"
    echo ""
}


# Download Elastic Start-Local Script
report_status "Downloading Elastic Start-Local Script"
curl -fsSL https://elastic.co/start-local | sh
report_status " -- complete"

# Verify environment file exists
report_status "Verifying environment file from Elastic Start-Local exists"
ENV_FILE="$SCRIPT_DIR/elastic-start-local/.env"

if [ ! -f "$ENV_FILE" ]; then
    echo "Error: File '$ENV_FILE' does not exist."
    exit 1
fi
report_status "-- complete"

# Load environment variables from the file
report_status "Loading environment variables from file"
export $(grep -v '^#' "$ENV_FILE" | xargs)
report_status " -- complete"

# BASE64 username and password for use with curl basic auth
BASE64=$(echo -n "elastic:${ES_LOCAL_PASSWORD}" | base64)

# Download sample data from Dropbox share
report_status "Downloading sample data"
mkdir $SCRIPT_DIR/workshop-data
cd  $SCRIPT_DIR/workshop-data
retry_command wget -q -r "https://www.dropbox.com/scl/fo/qvi7j9c2np1dxmb2j5djp/AIFtobJY3pZuorWzpa5pSq0?rlkey=yqzx7mylg67x06a7feniubm72&st=umyakvrj&dl=1" -O files.zip
unzip files.zip -x /
report_status " -- complete"

# Upload Elasticsearch Trimet index template
report_status "Uploading Elasticsearch index template for sample data"
retry_command curl --silent --show-error --fail -X PUT "$ES_LOCAL_URL/_index_template/trimet-geo-workshop-template" \
-H "Content-Type: application/json" \
-H "Authorization: Basic $BASE64" \
-d @trimet-geo-workshop-index-template.json
report_status " -- complete"

# Upload Elasticsearch Portland GeoJSON index template
report_status "Uploading Elasticsearch index template for Portland GeoJSON data"
retry_command curl --silent --show-error --fail -X PUT "$ES_LOCAL_URL/_index_template/portland-geojson-template" \
-H "Content-Type: application/json" \
-H "Authorization: Basic $BASE64" \
-d @portland-geojson-index-template.json
report_status " -- complete"

# Install required Python libraries
report_status "Installing Python libraries"
pip3 install -q argparse elasticsearch tqdm
report_status " -- complete"

# Upload CSV data to Elasticsearch
report_status "Uploading Trimet CSV data to Elasticsearch"
python3 upload-csv-elasticsearch.py --csv trimet-geo-workshop-data.csv --host $ES_LOCAL_URL --password $ES_LOCAL_PASSWORD
report_status " -- complete"

# Upload GeoJSON data to Elasticsearch
report_status "Uploading GeoJSON data to Elasticsearch"
python3 upload-geojson-elasticsearch.py --json portland-geojson.json --host $ES_LOCAL_URL --password $ES_LOCAL_PASSWORD
report_status " -- complete"

# Upload Trimet dataview to Kibana"
report_status "Uploading Trimet dataview to Kibana"
curl \
 -X POST http://localhost:5601/api/data_views/data_view \
 -H "Authorization: Basic $BASE64" \
 -H "Content-Type: application/json; Elastic-Api-Version=2023-10-31" \
 -H "kbn-xsrf: string" \
 -d @trimet-geo-workshop-dataview.json
report_status " -- complete"

report_status "Local Development Environment Setup Complete"
report_status "Elasticsearch URL: $ES_LOCAL_URL\n Elasticsearch Username: elastic\n Elasticsearch Password: $ES_LOCAL_PASSWORD"