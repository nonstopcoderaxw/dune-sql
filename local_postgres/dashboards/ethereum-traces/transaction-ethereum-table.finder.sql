with calls_base as (
        SELECT 
            tr.trace_address
            , case 
                when c.namespace is not null then concat(c.namespace, '_', 'ethereum', '.', c.name, '_call_', split_part(sig.signature,'(',1))
                when tr.type = 'create' then 'trace_create (' || COALESCE(lower(replace(c.name, ': ', '_ethereum.')), cast(tr.address as varchar)) || ')'
                when LENGTH(tr.input) = 0 then 'trace_' || tr.call_type --empty input implies just a value transfer or something was used.
                else 'unknown_call (' || cast(SUBSTR(tr.input,1,10) as varchar) || ')'
            end
            as decoded_table_name
            , coalesce(sig.signature, '_unknown_') as function_event
            , COALESCE(tr.to, tr.address) as contract_address
            , tr.success
            , tr."from"
            , SUBSTR(tr.input,1,10) as signature,
            json_value(sig.abi, 'stateMutability') as function_type
            , call_type
        FROM "ethereum.traces" tr
        LEFT JOIN "evms.contracts.last_submitted" c
            ON blockchain = 'ethereum' 
            and (c.address = tr.address OR c.address = tr.to)
            and last_submitted = 1
        LEFT JOIN "ethereum.signatures" sig ON SUBSTR(input, 1, 10) = sig.id AND sig.name = c.name AND sig.namespace = c.namespace
        WHERE tr.tx_hash = '0xb45f940a8e32d1cc52921a20d3d18b30dd511241a82396e44076dcca3277bd1c'
        and tr.block_number = '15253444'
        order by trace_address asc
    ),
logs_base as (
        SELECT 
            case 
                when c.namespace is not null then concat(c.namespace, '_', 'ethereum', '.', c.name, '_evt_', split_part(sig.signature,'(',1))
                else 'unknown_log (' || cast(topic0 as varchar) || ')'
            end
            as decoded_table_name
            , coalesce(sig.signature, '_unknown_') as function_event
            , row_number() over (partition by contract_address order by index asc) as event_log_count
            , contract_address
            , index
            , topic0 as signature
        from "ethereum.logs" l
        LEFT JOIN "evms.contracts.last_submitted" c
            ON blockchain = 'ethereum' 
            and c.address = l.contract_address
            and last_submitted = 1
        LEFT JOIN "ethereum.signatures" sig ON topic0 = sig.id AND sig.name = c.name AND sig.namespace = c.namespace
        WHERE l.tx_hash = '0xb45f940a8e32d1cc52921a20d3d18b30dd511241a82396e44076dcca3277bd1c'
        and l.block_number = '15253444'
        order by index asc
    ),
select * from logs_base
    