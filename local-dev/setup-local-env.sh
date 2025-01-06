#!/bin/bash 

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

# Function to report status messages reducing duplication
report_status(message)
{
    echo ""
    echo "$message"
    echo ""
}

# BEGIN WORKSHOP SETUP

# Download Elastic Start-Local Script
curl -fsSL https://elastic.co/start-local | sh

# Download sample data from Dropbox share
report_status("Downloading sample data")
mkdir elastic-geospatial-workshop
cd elastic-geospatial-workshop
retry_command wget -q -r "https://www.dropbox.com/scl/fo/qvi7j9c2np1dxmb2j5djp/AIFtobJY3pZuorWzpa5pSq0?rlkey=yqzx7mylg67x06a7feniubm72&st=umyakvrj&dl=1" -O files.zip
unzip files.zip 
report_status("Download sample data complete")

# Upload Elasticsearch Trimet index template
report_status("Uploading Elasticsearch index template for sample data")
retry_command curl --silent --show-error --fail -X PUT "$ELASTICSEARCH_URL/_index_template/trimet-geo-workshop-template" \
-H "Content-Type: application/json" \
-H "Authorization: Basic $BASE64" \
-d @trimet-geo-workshop-index-template.json
report_status("Upload Elasticsearch index template complete")

# Upload Elasticsearch Portland GeoJSON index template
report_status("Uploading Elasticsearch index template for Portland GeoJSON data")
retry_command curl --silent --show-error --fail -X PUT "$ELASTICSEARCH_URL/_index_template/portland-geojson-template" \
-H "Content-Type: application/json" \
-H "Authorization: Basic $BASE64" \
-d @portland-geojson-index-template.json
report_status("Upload Elasticsearch index template complete")

# Install required Python libraries
report_status("Installing Python libraries")
pip install -q argparse elasticsearch tqdm
report_status("Installation Python libraries complete")

# Upload CSV data to Elasticsearch
report_status("Uploading Trimet CSV data to Elasticsearch")
python3 upload-csv-elasticsearch.py --csv trimet-geo-workshop-data.csv --host $ELASTICSEARCH_URL --password $ELASTICSEARCH_PASSWORD

# Upload GeoJSON data to Elasticsearch
report_status("Uploading GeoJSON data to Elasticsearch")
python3 upload-geojson-elasticsearch.py --json portland-geojson.json --host $ELASTICSEARCH_URL --password $ELASTICSEARCH_PASSWORD

# Upload Trimet dataview to Kibana"
report_status("Uploading Trimet dataview to Kibana")
curl \
 -X POST $KIBANA_URL/api/data_views/data_view \
 -H "Authorization: Basic $BASE64" \
 -H "Content-Type: application/json; Elastic-Api-Version=2023-10-31" \
 -H "kbn-xsrf: string" \
 -d @trimet-geo-workshop-dataview.json
report_status("Upload Kibana dataview complete")

report_status("Upload complete")

report_status("Local Development Environment Setup Complete")