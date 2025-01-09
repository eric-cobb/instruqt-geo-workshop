#!/bin/bash
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "${SCRIPT_DIR}"

# -----------------------------------------------------------------------------
# Check for cleanup mode
# -----------------------------------------------------------------------------
if [ $# -eq 2 ]; then
    if [ "$1" = "cleanup" ]; then
        case "$2" in
            elastic-start-local)
                # Run uninstall script if it exists
                if [ -f "elastic-start-local/uninstall.sh" ]; then
                    echo "Running uninstall script for elastic-start-local..."
                    bash "elastic-start-local/uninstall.sh"
                fi

                # Remove elastic-start-local directory
                echo "Removing elastic-start-local directory..."
                rm -rf "elastic-start-local"
                echo "Cleanup of elastic-start-local complete."
                ;;

            instruqt-geo-workshop)
                # Remove instruqt-geo-workshop directory
                echo "Removing instruqt-geo-workshop directory..."
                rm -rf "instruqt-geo-workshop"
                echo "Cleanup of instruqt-geo-workshop complete."
                ;;
            all)
                # Run uninstall script if it exists
                if [ -f "elastic-start-local/uninstall.sh" ]; then
                    echo "Running uninstall script for elastic-start-local..."
                    bash "elastic-start-local/uninstall.sh"
                fi

                # Remove elastic-start-local directory
                echo "Removing elastic-start-local directory..."
                rm -rf "elastic-start-local"
                echo "Cleanup of elastic-start-local complete."

                # Remove instruqt-geo-workshop directory
                echo "Removing instruqt-geo-workshop directory..."
                rm -rf "instruqt-geo-workshop"
                echo "Cleanup of instruqt-geo-workshop complete."
                ;;

            *)
                echo "Error: Unknown second parameter '$2'."
                echo "Usage: $0 cleanup [elastic-start-local | instruqt-geo-workshop | all]"
                exit 1
                ;;
        esac
    fi
fi

# -----------------------------------------------------------------------------
# If not running in cleanup mode, proceed with normal script logic
# -----------------------------------------------------------------------------

# Function to retry a command with exponential backoff
retry_command() {
    local max_attempts=10
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
    echo -e "$@"
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

# Check Python .venv
PYTHON_ENV="$SCRIPT_DIR/.venv"
report_status "Checking for Python $PYTHON_ENV"
if [ ! -d "$PYTHON_ENV" ]; then
    report_status " Python $PYTHON_ENV does not exist, creating"
    python3 -m venv "$PYTHON_ENV"
    report_status " -- complete"
fi
report_status "Python $PYTHON_ENV exists"

# Clone the workshop git repo which contains the sample data.
report_status "Downloading workshop git repo"
retry_command git clone https://github.com/eric-cobb/instruqt-geo-workshop.git
DATA_DIR="$SCRIPT_DIR/instruqt-geo-workshop/workshop-data"
report_status " -- complete"

cd "$DATA_DIR"

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

PYTHON3="$PYTHON_ENV/bin/python3"
PIP3="$PYTHON_ENV/bin/pip3"

# Install required Python libraries
report_status "Installing Python libraries"
"$PIP3" install -q argparse elasticsearch tqdm pip --upgrade
report_status " -- complete"

# Upload CSV data to Elasticsearch
report_status "Uploading Trimet CSV data to Elasticsearch"
"$PYTHON3" upload-csv-elasticsearch.py --csv trimet-geo-workshop-data.csv --host "$ES_LOCAL_URL" --password "$ES_LOCAL_PASSWORD"
report_status " -- complete"

# Upload GeoJSON data to Elasticsearch
report_status "Uploading GeoJSON data to Elasticsearch"
"$PYTHON3" upload-geojson-elasticsearch.py --json portland-geojson.json --host "$ES_LOCAL_URL" --password "$ES_LOCAL_PASSWORD"
report_status " -- complete"

# Upload Trimet dataview to Kibana
report_status "Uploading Trimet dataview to Kibana"
curl \
 -X POST http://localhost:5601/api/data_views/data_view \
 -H "Authorization: Basic $BASE64" \
 -H "Content-Type: application/json; Elastic-Api-Version=2023-10-31" \
 -H "kbn-xsrf: string" \
 -d @trimet-geo-workshop-dataview.json
report_status " -- complete"

report_status "Local Development Environment Setup Complete"
report_status "Elasticsearch URL: $ES_LOCAL_URL\nElasticsearch Username: elastic\nElasticsearch Password: $ES_LOCAL_PASSWORD"
