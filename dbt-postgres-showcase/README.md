https://medium.com/israeli-tech-radar/first-steps-with-dbt-over-postgres-db-f6b350bf4526

https://about.gitlab.com/handbook/business-technology/data-team/platform/dbt-guide/

``` bash
cd dbt-postgres-showcase
echo  "venv" >> .gitignore
python3 -m venv venv
source ./venv/bin/activate
pip install dbt-postgres
dbt --version

# https://docs.sqlfmt.com/integrations/dbt-power-user
# pip install 'shandy-sqlfmt[jinjafmt]'
pipx ensurepath
pipx install 'shandy-sqlfmt[jijnafmt]'

```

install the dbt-power-user vscode extension, and switch your python interpreter to this virtual environment

Then add the following to your vscode workspace settings section: 
``` yaml

		"[jijna-sql]": {
			"editor.defaultFormatter": "innoverio.vscode-dbt-power-user",
			"editor.formatOnSave": false //Optional, I prefer to format manually.
		  } 
```

A new directory and file will have been created in `~/.dbt/profiles.yml`  Add the folder to vscode workspace, or just edit the profiles.yaml in whatever tool you want and fill in the connection details.


# Postgres Setup

## Source

Same as postgres-setup.md

## Destination

Same as postgres-setup.md (LAKEDB)


# Transform

``` bash
dbt init pinnacle
# select postgres

cd pinnacle
dbt debug
# Expect an error

## Copy over thje model created from previous attempt

dbt run

```


# dbt-osmois
https://z3z1ma.github.io/dbt-osmosis/docs/tutorial-basics/installation

Add the following line to the `dbt_project.yaml` file: 
``` yaml
models:
  your_project_name:
    +dbt-osmosis: "_{model}.yml"
```
``` bash 
pipx install dbt-osmosis
pipx inject dbt-osmosis dbt-postgres
cd dbt-postgres-showcase/pinnacle
dbt-osmosis yaml refactor
```

