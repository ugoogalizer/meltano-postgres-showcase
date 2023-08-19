Aim of this project is to create a working showcase of Meltano with extras.

1. [Populate a source Postgresql database](postgres-setup.md), with data that changes over time.  Aim to reuse/build on the work from here: https://github.com/Noosarpparashar/startupv2/tree/master/python/dataGenerator/ecart_v2
1. [Pull that postgres database with Meltano](meltano-setup.md) (Extract + Load) and load back into a different Postgres database
1. Transform that loaded data with DBT
1. STRETCH - Visualise that data with Superset (something like this speedrun video: https://www.youtube.com/watch?v=sL3RvXZOTvE)
1. STRETCH - Load  that data into Neo4j (ideally with DBT / Meltano if possible)
1. STRETCH - Load using Kafka or similar message bus
