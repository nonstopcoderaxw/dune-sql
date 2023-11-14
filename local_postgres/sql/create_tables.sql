-- STEP 1
DROP TABLE if exists "cex.addresses" CASCADE;

DROP TABLE if exists "ethereum.traces" CASCADE;

DROP TABLE if exists "ethereum.transactions" CASCADE;

DROP TABLE if exists "evms.contracts" CASCADE;

DROP TABLE if exists "ethereum.signatures" CASCADE;

DROP TABLE if exists "ethereum.logs" CASCADE;

-- STEP 2
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
    trace_address int8[],
    type TEXT,
    address TEXT,
    code TEXT,
    call_type TEXT,
    input TEXT,
    output TEXT,
    refund_address TEXT,
    block_date date
);

CREATE TABLE "ethereum.transactions"(
    block_time timestamp,
    block_number int8,
    value int8,
    gas_limit int8,
    gas_price int8,
    gas_used int8,
    max_fee_per_gas int8,
    max_priority_fee_per_gas int8,
    priority_fee_per_gas int8,
    nonce int8,
    index int8,
    success bool,
    "from" TEXT,
    "to" TEXT,
    block_hash TEXT,
    data TEXT,
    hash TEXT,
    type TEXT,
    access_list TEXT,
    block_date date
);

CREATE TABLE "evms.contracts"(
    blockchain TEXT,
    abi TEXT,
    address TEXT,
    "from" TEXT,
    code TEXT,
    name TEXT,
    namespace TEXT,
    dynamic TEXT,
    base TEXT,
    factory TEXT,
    detection_source TEXT,
    created_at TEXT
);

CREATE TABLE "ethereum.signatures"(
    id TEXT,
    signature TEXT,
    abi TEXT,
    type TEXT,
    namespace TEXT,
    name TEXT,
    created_at timestamp
);

CREATE TABLE "ethereum.logs"(
    block_time timestamp,
    block_number int8,
    block_hash TEXT,
    contract_address TEXT,
    topic0 TEXT,
    topic1 TEXT,
    topic2 TEXT,
    topic3 TEXT,
    data TEXT,
    tx_hash TEXT,
    index int8,
    tx_index int8,
    block_date date,
    tx_from TEXT,
    tx_to TEXT
);