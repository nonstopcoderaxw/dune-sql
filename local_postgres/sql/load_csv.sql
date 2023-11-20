DELETE FROM
    "ethereum.traces";

DELETE FROM
    "ethereum.transactions";

DELETE FROM
    "evms.contracts";

DELETE FROM
    "ethereum.signatures";

DELETE FROM
    "ethereum.logs";

DELETE FROM
    "ethereum.contracts";

DELETE FROM
    "labels.contracts";

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
    '/Volumes/t7/mac/gitProjects/dune-sql/csv/to-be-loaded/ethereum.traces.csv' DELIMITER ',' CSV HEADER;

COPY "ethereum.transactions"(
    block_time,
    block_number,
    value,
    gas_limit,
    gas_price,
    gas_used,
    max_fee_per_gas,
    max_priority_fee_per_gas,
    priority_fee_per_gas,
    nonce,
    index,
    success,
    "from",
    "to",
    block_hash,
    data,
    hash,
    type,
    access_list,
    block_date
)
FROM
    '/Volumes/t7/mac/gitProjects/dune-sql/csv/to-be-loaded/ethereum.transactions.csv' DELIMITER ',' CSV HEADER;

COPY "evms.contracts"(
    blockchain,
    abi,
    address,
    "from",
    code,
    name,
    namespace,
    dynamic,
    base,
    factory,
    detection_source,
    created_at
)
FROM
    '/Volumes/t7/mac/gitProjects/dune-sql/csv/to-be-loaded/evms.contracts.csv' DELIMITER ',' CSV HEADER;

COPY "ethereum.signatures"(
    id,
    signature,
    abi,
    type,
    namespace,
    name,
    created_at
)
FROM
    '/Volumes/t7/mac/gitProjects/dune-sql/csv/to-be-loaded/ethereum.signatures.csv' DELIMITER ',' CSV HEADER;

COPY "ethereum.logs"(
    block_time,
    block_number,
    block_hash,
    contract_address,
    topic0,
    topic1,
    topic2,
    topic3,
    data,
    tx_hash,
    index,
    tx_index,
    block_date,
    tx_from,
    tx_to
)
FROM
    '/Volumes/t7/mac/gitProjects/dune-sql/csv/to-be-loaded/ethereum.logs.csv' DELIMITER ',' CSV HEADER;

COPY "ethereum.contracts"(
    abi_id,
    abi,
    address,
    "from",
    code,
    name,
    namespace,
    dynamic,
    base,
    factory,
    detection_source,
    created_at
)
FROM
    '/Volumes/t7/mac/gitProjects/dune-sql/csv/to-be-loaded/ethereum.contracts.csv' DELIMITER ',' CSV HEADER;

COPY "labels.contracts"(
    blockchain,
    address,
    name,
    category,
    contributor,
    source,
    created_at,
    updated_at,
    model_name,
    label_type
)
FROM
    '/Volumes/t7/mac/gitProjects/dune-sql/csv/to-be-loaded/labels.contracts.csv' DELIMITER ',' CSV HEADER;