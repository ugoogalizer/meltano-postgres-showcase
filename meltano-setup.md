

# Meltano

## Meltano Pre-Reqs

https://www.centlinux.com/2022/06/how-to-install-python-310-on-rocky-linux.html

``` bash
sudo dnf install -y curl gcc openssl-devel bzip2-devel libffi-devel zlib-devel tar wget make sqlite-devel
cd /tmp
#Check for latest version here: https://www.python.org/ftp/python/
wget https://www.python.org/ftp/python/3.10.11/Python-3.10.11.tar.xz
sudo tar -xf Python-3.10.11.tar.xz -C /opt/
sudo chown matt:matt -R /opt/Python-3.10.11/
cd /opt/Python-3.10.11/
./configure --enable-optimizations --enable-loadable-sqlite-extensions 
make -j 2
sudo make altinstall

#The binary is `python3.10`, optionally add the following line to your `~/.bashrc` file:
  alias python3="python3.10"

echo 'alias python3="python3.10"' >> ~/.bashrc

source ~/.bashrc

```


Optional - Mount a location that you can see the files that Meltano creates (say within VSCode from your desktop)
``` bash
sudo mkdir /media/devspace
sudo mount -t nfs -o vers=4,nolock,local_lock=all 192.168.2.22:/volume1/Dropbox/devspace /media/devspace/

sudo useradd dev -u 1025 -G wheel
sudo passwd dev
su dev

sudo yum install cifs-utils
# mount -t cifs -o username=guest,password=Password1 //192.168.2.22/Drobox /media/devspace

sudo chown matt:matt /media/devspace/
sudo chmod 770 /media/devspace
# Then mount this same location on your workstation...
```

Optional - Install DBT and dbt-power-user vscode extension
``` bash
#create a venv
# cd to root of your git repo
# python3 -m venv pythonenv
# source ./pythonenv/bin/activate
# pip install dbt-postgres
# touch meltano-projects/my-meltano-project/.meltano/transformers/dbt-profile.yml

```
Now install the dbt-power-user vscode extension, and switch your python interpreter to this virtual environment

## Install and Configure Meltano

``` bash
# Install Meltano

python3 -m pip install --user pipx
python3 -m pipx ensurepath
source ~/.bashrc
pipx install meltano
meltano --version

# Initialise Meltano
mkdir meltano-projects
cd meltano-projects
meltano init my-meltano-project
cd my-meltano-project

``` 
## EXTRACT - Configure a Postgres Tap (source) with a dummy output 
``` bash
# Install Postgres Tap (source)
meltano add extractor tap-postgres

# Basic connection details (but not schema)
meltano config tap-postgres set --interactive
## Steps I used: 
## 2 database
## 5 host
## 9 password
## 27 user
## e exit

# Select only what we want
meltano select tap-postgres --list --all
# meltano select tap-postgres ecart-customer.*
meltano select tap-postgres --list --all
# set replication method to key based incremental
meltano config tap-postgres set _metadata secart-customer replication-method INCREMENTAL
meltano config tap-postgres set _metadata secart-customer replication-key custid
# meltano config tap-postgres set _metadata '*' replication-method INCREMENTAL

#Add a dummy loader to dump the data into JSON
meltano add loader target-jsonl --variant=andyh1203

#Test the run
meltano run tap-postgres target-jsonl
meltano run tap-postgres target-jsonl --full-refresh

``` 
You should see data flowing from your source into the jsonl file. You can verify that it worked by looking inside the newly created file called output/*.jsonl.

## LOAD - Configure a Postgres Target (Destination) 
Useful doco: https://hub.meltano.com/loaders/target-postgres/

``` bash
# Install the Postgres Target (destination)
meltano add loader target-postgres

# Basic connection details (but not schema), alternatively you could just copy the yaml cofnig from the tap...
meltano config target-postgres set --interactive
## Steps I used: 
## 2 database
## 5 host
## 9 password
## 27 user
## e exit

# Extra settings that aren't found in the interactive screen: 
meltano config target-postgres set default_target_schema ecart_raw
# meltano config target-postgres set flattening_enabled [value]

#Log based and Incremental replications on tables with no Primary Key cause duplicates when merging UPDATE events. When set to true, stop loading data if no Primary Key is defined.
# UPDATE This doesn't work for the Meltano variant of target-postgres
# meltano config target-postgres set primary_key_required true

# Run ti
meltano run tap-postgres target-postgres

# Run it full from scratch (not sure it drops the records first though!!!)
meltano run tap-postgres target-postgres --full-refresh

```

## TRANSFORM - Transform loaded data in destination Postgres with DBT

References: 
 - https://docs.meltano.com/getting-started/#transform-loaded-data-for-analysis
 - https://hub.meltano.com/transformers/dbt-postgres--dbt-labs

Tutorials:
 https://docs.meltano.com/getting-started/#transform-loaded-data-for-analysis


``` bash 
# Install the target specific transformer to the project
meltano add transformer dbt-postgres

# Configure dbt-postgres
meltano config dbt-postgres list

# For example:
meltano config dbt-postgres set host 10.20.10.0
meltano config dbt-postgres set user meltano
meltano config dbt-postgres set password password
meltano config dbt-postgres set port 5432
meltano config dbt-postgres set dbname lakedb
meltano config dbt-postgres set schema ecart_raw

# Create a basic transform file
mkdir ./transform/models/tap_postgres
touch  ./transform/models/tap_postgres/source.yml
touch  ./transform/models/tap_postgres/orders_denormalised.sql
# See the content comitted in version control for this.

# Run the Transformer
meltano run dbt-postgres:run
meltano run dbt-postgres:run --full-refresh # doesn't work

meltano invoke --list-commands dbt-postgres
meltano invoke dbt-postgres --help
meltano invoke dbt-postgres run --help
meltano invoke dbt-postgres run --select tap_postgres+
meltano invoke dbt-postgres run --full-refresh --select tap_postgres+

# https://hub.meltano.com/transformers/dbt/#commands

# DBT guides: 
https://docs.getdbt.com/docs/build/incremental-models
https://medium.com/@suffyan.asad1/getting-started-with-dbt-data-build-tool-a-beginners-guide-to-building-data-transformations-28e335be5f7e

```

# Scheduling (with airflow)

https://docs.meltano.com/guide/orchestration
https://hub.meltano.com/utilities/airflow/

To use airflow, we have a choice: either install a local airflow within Meltano, or use an external one.  For simplicity to start with, we'll use the internal Airflow... (but presume an external one would be better in the long run..)

## Create a Schedule
https://docs.meltano.com/reference/command-line-interface/#schedule
``` bash
# Define a job
meltano job add tap-postgres-to-target-postgres-with-dbt --tasks "tap-postgres target-postgres dbt-postgres:run"

# Schedule the job (every 5 minutes)
meltano --environment=dev schedule add fivemin-postgres-load --job tap-postgres-to-target-postgres-with-dbt --interval '*/5 * * * *' 


#Other useful commands: 
meltano schedule list
meltano schedule remove fivemin-postgres-load
```

## Install Airflow

``` bash
meltano add utility airflow
meltano invoke airflow:initialize
meltano invoke airflow users create -u admin@localhost -p password --role Admin -e admin@localhost -f admin -l admin

```
## Start the scheduler: 
This will now not only convert your defined schedules (confirmed from `meltano schedule list`) but also actualy schedules/runs them:
``` bash
meltano invoke airflow scheduler
```


## Access the Airflow UI  (not required, but fun)
``` bash
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload
meltano invoke airflow webserver # note this is a terminal blocking command
```

Kill things: 
``` bash
sudo lsof -i:8080
kill $(ps -o ppid= $(cat ./orchestrate/airflow/airflow-webserver.pid))
sudo lsof -i:8080

# Get the process group id (PGID), then kill that entire group
sudo lsof -i:8080 -g 
kill -- -189345
sudo lsof -i:8080
```

# Analyse with Superset

# CI/CD


# Containerise & Productionise Project

https://docs.meltano.com/guide/production/#running-pipelines

# TODO
 - Transform data with DBT - DONE (basic)
 - Visualise data with Superset
 - Split project into functional environments (dev, qa, prod ...)
 - Productionise / Containerise: 
     - Setup secrets to be safely handled (in k8s need to use k8s secrets...)
 - Test out log based incremental loads from Postgres (rather than key based)
 - Scheduling (with an orchestrator?) - DONE (basic)
 - Pipe data (somehow) to a graph..
 - Deal with changes to dimensions in the data model (aka, look at slowly changing dimension options.)



# Other references: 
https://meltano.com/blog/5-helpful-extract-load-practices-for-high-quality-raw-data/
https://meltano.com/blog/top-5-of-dbt-packages-and-tools-in-2022/


# Testing out against an API 

https://hub.meltano.com/extractors/tap-rest-api-msdk/#num_inference_records-setting
https://earthquake.usgs.gov/fdsnws/event/1/
https://engineering.widen.com/blog/Dagster-+-Meltano/

``` bash
meltano add extractor tap-rest-api-msdk

# Already done
# meltano add loader target-jsonl

meltano config tap-rest-api-msdk set --interactive
meltano config tap-rest-api-msdk list
meltano select --list --all tap-rest-api-inc
# Copy from the yaml file

meltano elt tap-rest-api-msdk target-jsonl 
meltano elt tap-rest-api-msdk target-postgres
meltano elt tap-rest-api-incremental target-postgres

```


``` sql
-- Table: ecart_raw.us_earthquakes

-- DROP TABLE IF EXISTS ecart_raw.us_earthquakes;

CREATE TABLE IF NOT EXISTS ecart_raw.us_earthquakes
(
    type character varying COLLATE pg_catalog."default",
    properties_mag numeric,
    properties_place character varying COLLATE pg_catalog."default",
    properties_time TIMESTAMP WITH TIME ZONE,
    properties_updated TIMESTAMP WITH TIME ZONE,
    properties_tz character varying COLLATE pg_catalog."default",
    properties_url character varying COLLATE pg_catalog."default",
    properties_detail character varying COLLATE pg_catalog."default",
    properties_felt bigint,
    properties_cdi numeric,
    properties_mmi numeric,
    properties_alert character varying COLLATE pg_catalog."default",
    properties_status character varying COLLATE pg_catalog."default",
    properties_tsunami bigint,
    properties_sig bigint,
    properties_net character varying COLLATE pg_catalog."default",
    properties_code character varying COLLATE pg_catalog."default",
    properties_ids character varying COLLATE pg_catalog."default",
    properties_sources character varying COLLATE pg_catalog."default",
    properties_types character varying COLLATE pg_catalog."default",
    properties_nst bigint,
    properties_dmin numeric,
    properties_rms numeric,
    properties_gap numeric,
    "properties_magType" character varying COLLATE pg_catalog."default",
    properties_type character varying COLLATE pg_catalog."default",
    properties_title character varying COLLATE pg_catalog."default",
    geometry_type character varying COLLATE pg_catalog."default",
    geometry_coordinates character varying COLLATE pg_catalog."default",
    id character varying COLLATE pg_catalog."default" NOT NULL,
    _sdc_extracted_at timestamp without time zone,
    _sdc_received_at timestamp without time zone,
    _sdc_batched_at timestamp without time zone,
    _sdc_deleted_at timestamp without time zone,
    _sdc_sequence bigint,
    _sdc_table_version bigint,
    _sdc_sync_started_at bigint,
    CONSTRAINT us_earthquakes_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS ecart_raw.us_earthquakes
    OWNER to postgres;

```


# Archived work
``` bash 


# Setup Git
# git config --global --add safe.directory /media/devspace/meltano-projects/my-meltano-project
# git config --global user.email "test@test.com"
# git config --global user.name "Test"

# Add version control
# git init
# git add --all
# git commit -m 'Initial Meltano project'

#Set to dev environment
meltano environment list
export MELTANO_ENVIRONMENT=dev


# View all extractors
meltano discover extractors
meltano discover extractors | grep git

# Install an extractor
meltano add extractor tap-gitlab
#To learn more about extractor 'tap-gitlab', visit https://hub.meltano.com/extractors/tap-gitlab--meltanolabs

# if you need to cache plugins offline:
# https://docs.meltano.com/guide/plugin-management/#installing-plugins-from-a-custom-python-package-index-pypi

meltano config tap-gitlab set --interactive

## SKIP to video content: 
meltano add extractor tap-github
meltano config tap-github set repository 'meltano/meltano'
meltano config tap-github set start_date 2022-06-01T:00:010:00Z

# Set which stream we want to pull
meltano --no-environment select tap-github commits "*"


```

