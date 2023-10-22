#!/bin/bash

# when a query returns non-zero, the script will be set to stop
set -e

psql -v ON_ERROR_STOP=1 --dbname "postgres" -f "create_tables.sql"