# Datasource

Intent is to re-use the work done from https://github.com/Noosarpparashar/startupv2/tree/master/python/dataGenerator/ecart_v2

## Get Postgres Database Running

Create the database (see k8s deployment) https://github.com/ugoogalizer/argo-cd/blob/main/apps/templates/postgresql-helm.yaml

## Generate data (over time)

On the postgres server: 

``` sql

create DATABASE PINNACLEDB;
ALTER USER postgres WITH REPLICATION;
\c pinnacledb;
create SCHEMA ECART;

create table ECART.CUSTOMER (
  CUSTID VARCHAR(50),
  CUSTNAME VARCHAR(100),
  CUSTADD VARCHAR(400)
); 

create table ECART.PRODUCTINFO (
  PRODUCTID INTEGER,
  PRODUCTNAME VARCHAR(150),
  PRODCAT VARCHAR(400),
  STOREID varchar(70)
);

create table ECART.STOREINFO (
  STOREID varchar(70),
  STORENAME VARCHAR(150),
  STOREADD VARCHAR(400)
);

create table ECART.FACT_ORDER (
  ORDERID SERIAL PRIMARY key,
  CUSTID VARCHAR(50),
  PRODUCTID INTEGER,
  PURCHASETIMESTAMP TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

```
