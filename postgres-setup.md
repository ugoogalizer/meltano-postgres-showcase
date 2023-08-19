# Datasource (Tap for Meltano)

This section creates a source database in PostgreSQL that incrementally adds data so we can test the incremental capabilities of downstream tools (i.e. Meltano/DBT).

Intent is to re-use the work done from https://github.com/Noosarpparashar/startupv2/tree/master/python/dataGenerator/ecart_v2

## Get Postgres Database Running

Create the database (see k8s deployment) https://github.com/ugoogalizer/argo-cd/blob/main/apps/templates/postgresql-helm.yaml

## Setup Schema

On the postgres server (I used pgadmin): 

``` sql

create DATABASE PINNACLEDB;
ALTER USER postgres WITH REPLICATION;
-- If using psql, switch to the new database with: 
-- \c pinnacledb;
create SCHEMA ECART;

create table ECART.CUSTOMER (
  CUSTID VARCHAR(50),
  CUSTNAME VARCHAR(100),
  CUSTADD VARCHAR(400),
  CREATEDTIMESTAMP TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UPDATEDTIMESTAMP TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
); 

create table ECART.PRODUCTINFO (
  PRODUCTID INTEGER,
  PRODUCTNAME VARCHAR(150),
  PRODCAT VARCHAR(400),
  STOREID varchar(70),
  CREATEDTIMESTAMP TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UPDATEDTIMESTAMP TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

create table ECART.STOREINFO (
  STOREID varchar(70),
  STORENAME VARCHAR(150),
  STOREADD VARCHAR(400),
  CREATEDTIMESTAMP TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UPDATEDTIMESTAMP TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

create table ECART.FACT_ORDER (
  ORDERID SERIAL PRIMARY key,
  CUSTID VARCHAR(50),
  PRODUCTID INTEGER,
  PURCHASETIMESTAMP TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

```


## Generate data (over time)


on a docker building server

``` bash
mkdir my-ecart-data-generator
cd  my-ecart-data-generator
git clone https://github.com/ugoogalizer/meltano-postgres-showcase.git
cd meltano-postgres-showcase/python
#docker build -t my-ecart-data-generator .
podman build -t my-ecart-data-generator .
podman run my-ecart-data-generator

```


##  Deleting Postgres content

If you need to delete all the content to start again without dropping schema: 
``` sql
DELETE FROM ECART.CUSTOMER;
DELETE FROM ECART.PRODUCTINFO ;
DELETE FROM ECART.STOREINFO ;
DELETE FROM ECART.FACT_ORDER;
```
If you need to drop all the tables (including content) to start again: 
``` sql
DROP TABLE ECART.CUSTOMER;
DROP TABLE ECART.PRODUCTINFO ;
DROP TABLE ECART.STOREINFO ;
DROP TABLE ECART.FACT_ORDER;
```

Target: 
If you need to drop all the tables (including content) to start again: 
``` sql
DROP TABLE ECART_RAW.CUSTOMER;
DROP TABLE ECART_RAW.PRODUCTINFO ;
DROP TABLE ECART_RAW.STOREINFO ;
DROP TABLE ECART_RAW.FACT_ORDER;
```

# Create Destination Database (Target for Meltano)

In Postgres: 

``` sql
create DATABASE LAKEDB;
-- If using psql, switch to the new database with: 
-- \c lakedb;
create SCHEMA ECART_RAW;

```