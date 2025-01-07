# Instruqt Geo Workshop

This project is for maintaining and collaborating on the Elastic Geo Workshop in Elastic's Instruqt account.

## Getting Started

Pull this repo.

```bash
git clone https://github.com/eric-cobb/instruqt-geo-workshop.git
```

## Dependencies

### Docker

This local development environment is dependent on Docker installed in your environment.  Generally, any Docker variation
(Docker Desktop, Rancher Desktop, etc) should work.

### wget and unzip

The `local-dev/setup-local-env.sh` script uses `wget` and `unzip`. These commands may not be installed by default in your
environment. On a Mac, you can install them easily with [Homebrew](https://brew.sh/).

```bash
brew install wget unzip
```

### python3 and pip3

The sample workshop data is loaded into Elasticsearch with a Python script. Your environment should have acccess to `python3`
and `pip3` commands. If you need to install Python, we recommend [uv](https://github.com/astral-sh/uv) for installing/managing
python versions, your python virtual environments, and your python requirements.

## Usage

To setup your local development environment, run `cd local-dev; ./setup-local-env.sh`.  This script will automate creating a
local development Elastic cluster with Elasticsearch and Kibana as Docker containers.

Development of workshop content is made more streamlined by using a local Elastic development cluster instead of starting up
the Instruqt workshop envvironment after every update. To make creating a local Elastic development cluster consistent and with
minimal effort, we use [Elastic Start-Local](https://www.elastic.co/guide/en/elasticsearch/reference/current/run-elasticsearch-locally.html).

Elastic Start-Local will create a directory named `elastic-start-local`.  The script will automatically create an Elastic
cluster in Docker. Elastic Start-Local provides scripts to start and stop the cluster in the `elastic-start-local` directory.

### Start the Elastic cluster

```bash
cd local-dev/elastic-start-local; ./start.sh
```

### Stop the Elastic cluster

```bash
cd local-dev/elastic-start-local; ./start.sh
```

### Fresh Elastic cluster

If you need a fresh Elastic cluster, you can  run `docker compose down` in the `local-dev/elastic-start-local` directory.

```bash
cd local-dev/elastic-start-local; docker compose down
```

Once the containers are removed, then you can run `cd local-dev/elastic-start-local/; ./start.sh` which will recreate the
Elastic cluster using the previously created `local-dev/elastic-start-local/.env file`.

Elastic Start-Local creates default passwords and api keys and stores them in `local-dev/elastic-start-local/.env`. If you
need to log into the local Elasticsearch or Kibana instance, you can find the passwords in the `.env` file.