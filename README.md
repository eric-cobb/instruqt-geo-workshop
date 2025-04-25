# Instruqt Geo Workshop

This project is for maintaining and collaborating on the Elastic Geo Workshop in Elastic's Instruqt account.

## Getting Started

Pull this repo.

```bash
git clone https://github.com/eric-cobb/instruqt-geo-workshop.git
```

## Dependencies

### Docker

This local development environment is dependent on Docker installed in your environment. Generally, any Docker variation
(Docker Desktop, Rancher Desktop, etc) should work.

### `wget` and `unzip`

The `local-dev/setup-local-env.sh` script uses `wget` and `unzip`. These commands may not be installed by default in your
environment.

On a Mac, you can install them easily with [Homebrew](https://brew.sh/).

```bash
brew install wget unzip
```

### `python3` and `pip3`

The sample workshop data is loaded into Elasticsearch with a Python script. Your environment should have acccess to `python3`
and `pip3` commands version 3.9 or newer. If you need to install Python, we recommend [uv](https://github.com/astral-sh/uv)
for installing/managing python versions, your python virtual environments, and your python requirements.

## Set Up Local Development Environment

To setup your local development environment, run `cd local-dev; ./setup-local-env.sh`. This script will automate creating a
local development Elastic cluster with Elasticsearch and Kibana as Docker containers. It then loads the workshop data into the local cluster.

Development of workshop content is made more streamlined by using a local Elastic development cluster instead of starting up
the Instruqt workshop envvironment after every update. To ensure the workshop environment is consistent between workshop developers, we use [Elastic Start-Local](https://www.elastic.co/guide/en/elasticsearch/reference/current/run-elasticsearch-locally.html).

Elastic Start-Local will create a directory named `elastic-start-local`. The script will automatically create an Elastic
cluster in Docker. Elastic Start-Local provides scripts to start and stop the cluster in the `elastic-start-local` directory.

### Start the Elastic cluster

```bash
cd local-dev/elastic-start-local; ./start.sh
```

### Stop the Elastic cluster

```bash
cd local-dev/elastic-start-local; ./start.sh
```

### Create Fresh Elastic cluster

If you need a fresh Elastic cluster, you can run `docker compose down` in the `local-dev/elastic-start-local` directory.

```bash
cd local-dev/elastic-start-local; docker compose down
```

Once the containers are removed, then you can run `cd local-dev/elastic-start-local/; ./start.sh` which will recreate the
Elastic cluster using the previously created `local-dev/elastic-start-local/.env file`.

Elastic Start-Local creates default passwords and api keys and stores them in `local-dev/elastic-start-local/.env`. If you
need to log into the local Elasticsearch or Kibana instance, you can find the passwords in the `.env` file.

## Instruqt

After your local Elastic cluster is setup and loaded with data, you can easily create Instruqt workshop content.

### Creating Content

The high-level workflow for creating content for an Instruqt workshop is:

- Identify the data necessary to support the intended audience of the workshop.
- Identify the Elastic components necessary to support the intended audience of the workshop.
- Determine the intended workflow for the user experience of your workshop content.
- Follow the workflow as the user would and take screenshots to be used as workshop content.
- Identify opportunities for checking user knowledge with quizzes.
- Identify opportunties for verifying actions performed by the user.
- Implement the Instruqt scripts to configure the environment and perform user action validations (`track_scripts`).

### Updating Content

For users or developers to see any new or updated content, you need to push that content to Insruqt.

To pull remote updates from Instruqt:

```bash
instruqt track pull
```
To validate your local changes:

```bash
instruqt track validate
```

To push local updates to Instruqt:

```bash
instruqt track push
```

If this process completes without errors, then you need to push your changes to git. Think of this as testing the workshop.

You should test your updates before pushing those changes to git to avoid any issues/conflicts that might arise.

```bash
git add -A
git commit -m "Describe Changes"
git push
```

If multiple developers are working on a workshop at the same time, you may run into conficts when you try to `instruqt track push`.

This is similar in nature to git merge issues. Before pushing your changes to Instruqt, it's a good idea to pull the latest
track version.

```bash
instruqt track pull
```

The `instruqt track pull` and `instruqt track push` commands will update content in the workshop `track.yml` file.  This file contains a checksum and other workshop metadata that may be updated within the Instruqt environment itself.

When there are conflicts performing a track pull or track push, it is often related to changes in track.yml.  Performing a `instruqt track pull` to fectch the current `live` version of the workshop can resolve these conflicts.

When there are conlicts, Instruqt will create *.remote files.  To resolve the conflicts, diff the local and `.remote` versions of the file and manually merge the changes.  Once you have done that you, can `instruqt track push`.

Once you have completed your updates, don't forget to merge your updates in to `git`.