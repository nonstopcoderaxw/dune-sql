# dune-sql
This project is to offer a SQL playground to run DuneSQL in a local postgres environment.

## Key project folders
- csv/to-be-loaded: csv files to be loaded by executing ```yarn 9.2:sql:load:csvs```
- csv/{sql_name}: csv files including sample data to execute SQLs
- dune/dune_sql_for_csv: DuneSQL to retrieve sample data
- local_postgres/dashboard: Postgre SQL to execute on sample data

### .env 
```
QUERY_ID=<Dune-Query-ID>
DUNE_API_KEY=<Dune-API-Key>
QUERY_RESULT_FILE=<Local-File-Name-For-Query-Result>
```

### Key commands
Retrieve dune data from a connected DuneSQL to ```QUERY_RESULT_FILE```

```shell
yarn 1:dune:import:csv
```

Convert dune query result into postgres-friendly
```shell
yarn 2.1:fix:dune:result
```

Copy dune result from ```QUERY_RESULT_FILE``` to ```./csv/to-be-loaded/{dune-table-name}```
```shell
yarn 3:copy:duneresult:to:csv ./csv/to-be-loaded/{dune-table-name}
```

Create dune tables in local postgres db
```shell
yarn 9.1:sql:create:tables:if:not
```

Create pre-defined sql functions in local postgres db
```shell
yarn 9.1.1:sql:create:functions:if:not
```

Load sample data from ```csv/to-be-loaded``` into local postgres
```shell
yarn 9.2:sql:load:csvs
```

Create/refresh materialized views
```shell
9.3:sql:create:refresh:mtrlzd:view
```


## Links
- Tool:
  - https://delim.co/#
  - https://onlinecsvtools.com/change-csv-delimiter
  - https://jsoneditoronline.org/

- TX visualizer
  - https://explorer.phalcon.xyz/
  - https://metasleuth.io

