

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

# Analyse with Superset

# CI/CD


# Containerise Project

# TODO
 - Transform data with DBT - DONE (basic)
 - Visualise data with Superset
 - Split project into functional environments (dev, qa, prod ...)
 - Setup secrets to be safely handled (in k8s need to use k8s secrets...)
 - Test out log based incremental (rather than key based)
 - Scheduling (with an orchestrator?)
 - Pipe data (somehow) to a graph..








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

