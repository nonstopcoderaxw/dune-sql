DROP TABLE if exists "cex.addresses";

DROP TABLE if exists "ethereum.traces";

CREATE TABLE "cex.addresses"(
    blockchain TEXT,
    address TEXT,
    cex_name TEXT,
    distinct_name TEXT,
    added_by TEXT,
    added_date date
);

CREATE TABLE "ethereum.traces"(
    block_time timestamp,
    block_number int8,
    value int8,
    gas int8,
    gas_used int8,
    block_hash TEXT,
    success bool,
    tx_index int8,
    sub_traces int8,
    error TEXT,
    tx_success bool,
    tx_hash TEXT,
    "from" TEXT,
    "to" TEXT,
    trace_address TEXT,
    type TEXT,
    address TEXT,
    code TEXT,
    call_type TEXT,
    input TEXT,
    output TEXT,
    refund_address TEXT,
    block_date date
);

COPY "cex.addresses"(
    blockchain,
    address,
    cex_name,
    distinct_name,
    added_by,
    added_date
)
FROM
    '/Volumes/t7/mac/gitProjects/dune-sql/src/postgres_scripts/csv/cex.addresses.csv' DELIMITER ',' CSV HEADER;

COPY "ethereum.traces"(
    block_time,
    block_number,
    value,
    gas,
    gas_used,
    block_hash,
    success,
    tx_index,
    sub_traces,
    error,
    tx_success,
    tx_hash,
    "from",
    "to",
    trace_address,
    type,
    address,
    code,
    call_type,
    input,
    output,
    refund_address,
    block_date
)
FROM
    '/Volumes/t7/mac/gitProjects/dune-sql/src/postgres_scripts/csv/ethereum.traces.csv' DELIMITER ',' CSV HEADER;