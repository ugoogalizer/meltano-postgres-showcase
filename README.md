Aim of this project was to create a working showcase of Meltano with extras.  However over time it became apparently that Meltano was not mature enough to cover all bases (even though it tries with its plugins) - so some comparative tests were run.

1. [Populate a source Postgresql database](postgres-setup.md), with data that changes over time.  Aim to reuse/build on the work from here: https://github.com/Noosarpparashar/startupv2/tree/master/python/dataGenerator/ecart_v2
1. [Pull that postgres database with Meltano](meltano-setup.md) (Extract + Load) and load back into a different Postgres database
1. Transform that loaded data with DBT
1. STRETCH - Visualise that data with Superset (something like this speedrun video: https://www.youtube.com/watch?v=sL3RvXZOTvE)
1. STRETCH - Load  that data into Neo4j (ideally with DBT / Meltano if possible)
1. STRETCH - Load using Kafka or similar message bus



# Evaluation: 

## Extract Load

### Meltano

Plus: 
 - Declarative
 - Documentation is good
 - Has plugs to include Transform, Orchestration, Visualisation (however these seems somewhat gimmicky and create lots of problems)
 - Simple enough secrets management
Con:
  - If not in documentation, other information (i.e. Community) is scarce.

### Airbyte

Not evaluted. 
Plus: 
 - Low code
 
Con: 
 - Not declarative

## Transform

### DBT Plugin within Meltano

Plus: 
 - Was easy to setup
Con:
 - Some commands simply don't work (like full-refresh on a incremental model) 
 - Couldn't get other tools in the DBT ecosphere to work (i.e. dbt-power-user for vscode) 
 - Really difficult to read the DBT logs (say if you're troubleshooting), because Meltano is very noisy and pulls apart the logs or something

### DBT (vanilla)

Plus: 
 - Much clearer logs/debug process
 - strong ecosphere of supporting tools
 - Simple enough secrets management
Con:
 - Slightly harder to 

## Orchestration

### Airflow Plugin within Meltano

Plus: 
 - Really simple to setup
 - Included a GUI
Con:
 - Lost visibility in each of the ELT steps, they were all bundled into one, which makes troubleshooting and replay harder.
 - Didn't seem to auto-retry on failure ... was a problem as it manually had to be re-run/failed.  Presume this can be fixed with a config change

### Airflow


### Prefect


### Dagster
