with calls_base as (
    SELECT
        tr.trace_address,
        case
            when c.namespace is not null then concat(
                c.namespace,
                '_',
                'ethereum',
                '.',
                c.name,
                '_call_',
                split_part(sig.signature, '(', 1)
            )
            when tr.type = 'create' then 'trace_create (' || COALESCE(
                lower(replace(c.name, ': ', '_ethereum.')),
                cast(tr.address as varchar)
            ) || ')'
            when LENGTH(tr.input) = 0 then 'trace_' || tr.call_type --empty input implies just a value transfer or something was used.
            else 'unknown_call (' || cast(SUBSTR(tr.input, 1, 10) as varchar) || ')'
        end as decoded_table_name,
        coalesce(sig.signature, '_unknown_') as function_event,
        COALESCE(tr.to, tr.address) as contract_address,
        tr.success,
        tr."from",
        SUBSTR(tr.input, 1, 10) as signature,
        json_value(sig.abi, 'stateMutability') as function_type,
        call_type
    FROM
        "ethereum.traces" tr
        LEFT JOIN "evms.contracts.last_submitted" c ON blockchain = 'ethereum'
        and (
            c.address = tr.address
            OR c.address = tr.to
        )
        and last_submitted = 1
        LEFT JOIN "ethereum.signatures" sig ON SUBSTR(input, 1, 10) = sig.id
        AND sig.name = c.name
        AND sig.namespace = c.namespace
    WHERE
        tr.tx_hash = '0xb45f940a8e32d1cc52921a20d3d18b30dd511241a82396e44076dcca3277bd1c'
        and tr.block_number = '15253444'
    order by
        trace_address asc
),
logs_base as (
    select
    	index,
        case
            when c.namespace is not null then concat(
                c.namespace,
                '_',
                'ethereum',
                '.',
                c.name,
                '_evt_',
                split_part(sig.signature, '(', 1)
            )
            else 'unknown_log (' || cast(topic0 as varchar) || ')'
        end as decoded_table_name,
        coalesce(sig.signature, '_unknown_') as function_event,
        row_number() over (
            partition by contract_address
            order by
                index asc
        ) as event_log_count,
        contract_address,
        topic0 as signature
    from
        "ethereum.logs" l
        LEFT JOIN "evms.contracts.last_submitted" c ON blockchain = 'ethereum'
        and c.address = l.contract_address
        and last_submitted = 1
        LEFT JOIN "ethereum.signatures" sig ON topic0 = sig.id
        AND sig.name = c.name
        AND sig.namespace = c.namespace
    WHERE
        l.tx_hash = '0xb45f940a8e32d1cc52921a20d3d18b30dd511241a82396e44076dcca3277bd1c'
        and l.block_number = '15253444'
    order by
        index asc
),
contract_call_count_trace as (
    SELECT
        *,
        row_number() over (
            partition by contract_address
            order by
                trace_address asc
        ) as contract_call_count
    FROM
        calls_base
    WHERE
        function_type not in ('view', 'pure')
        and call_type not in ('staticcall', 'delegatecall')
),
logs_ordered as (
    select
        l.decoded_table_name
        , l.function_event
        , c.contract_address
        --, get_href(get_chain_explorer_address('{{chain}}', l.contract_address), cast(l.contract_address as varchar)) as contract_address
        , null as "from"
        , l.signature
        , true as success
        , c.trace_address
        , coalesce(trace_address, lag(trace_address, 1) OVER (PARTITION BY 1 ORDER BY l.index asc)) as trace_address_1 --|| 9999 can be added to place the event at the very end of the trace.
        , l.index as evt_index
        , c.contract_call_count, l.event_log_count
    FROM
        logs_base l
        LEFT JOIN contract_call_count_trace c ON c.contract_address = l.contract_address
        AND c.contract_call_count = l.event_log_count
    order by
        l.index asc,
        c.trace_address asc, 
        l.event_log_count asc
)
SELECT
*
FROM (
SELECT 
    repeat('  ', cast(cardinality(trace_address) as int))
    || cast(cardinality(trace_address) as varchar) 
    || ' -> 🟢 '
    || call_type
        as tx_type
    , decoded_table_name
    , function_event
    --, get_href(get_chain_explorer_address('{{chain}}', contract_address),cast(contract_address as varchar)) as contract_address
    , "from"
    , signature
    , success
    , trace_address
    , null as evt_index
FROM calls_base
UNION ALL 
SELECT
    repeat('  ', cast(cardinality(trace_address) as int))
    || '  -> 🟠 event'
    as tx_type
    , decoded_table_name
    , function_event
    , "from"
    , signature
    , success
    , trace_address
    , null as evt_index
FROM logs_ordered
) al
WHERE (decoded_table_name not like '%unknown_%')
order by trace_address asc, evt_index asc nulls first