-- source: https://dune.com/ilemi/contract-quickstart
--basing off of https://explorer.phalcon.xyz/tx/eth/0x56aa11363ccf5c67092a5cde4c15f7f42cdfb503b191d1040ff1b9681566126c
with 
    calls_base as (
        SELECT 
            tr.trace_address
            , case 
                when c.namespace is not null then concat(c.namespace, '_', '{{chain}}', '.', c.name, '_call_', split_part(sig.signature,'(',1))
                when tr.type = 'create' then 'trace_create (' || COALESCE(lower(replace(c.name, ': ', '_{{chain}}.')), cast(tr.address as varchar)) || ')'
                when bytearray_length(tr.input) = 0 then 'trace_' || tr.call_type --empty input implies just a value transfer or something was used.
                else 'unknown_call (' || cast(bytearray_substring(tr.input,1,4) as varchar) || ')'
            end
            as decoded_table_name
            , coalesce(sig.signature, '_unknown_') as function_event
            , COALESCE(tr.to, tr.address) as contract_address
            , tr.success
            , tr."from"
            , bytearray_substring(tr.input,1,4) as signature
            , json_value(sig.abi, 'strict $.stateMutability') as function_type
            , call_type
        FROM {{chain}}.traces tr
        LEFT JOIN (SELECT *, row_number() over (partition by blockchain, address order by created_at desc) as last_submitted 
            FROM evms.contracts) c
            ON blockchain = '{{chain}}' 
            and (c.address = tr.address OR c.address = tr.to)
            and last_submitted = 1
        LEFT JOIN {{chain}}.signatures sig ON bytearray_substring(input,1,4) = sig.id AND sig.name = c.name AND sig.namespace = c.namespace
        WHERE tr.tx_hash = {{tx hash}}
        and tr.block_number = {{blocknumber}}
        -- AND lower(tr.function_name) NOT LIKE '%approve%' --here just to simplify the example case
        order by trace_address asc
    )

    , logs_base as (
        SELECT 
            case 
                when c.namespace is not null then concat(c.namespace, '_', '{{chain}}', '.', c.name, '_evt_', split_part(sig.signature,'(',1))
                else 'unknown_log (' || cast(topic0 as varchar) || ')'
            end
            as decoded_table_name
            , coalesce(sig.signature, '_unknown_') as function_event
            , row_number() over (partition by contract_address order by index asc) as event_log_count
            , contract_address
            , index
            , topic0 as signature
        FROM {{chain}}.logs l
        LEFT JOIN (SELECT *, row_number() over (partition by blockchain, address order by created_at desc) as last_submitted 
            FROM evms.contracts) c
            ON blockchain = '{{chain}}' 
            and c.address = l.contract_address
            and last_submitted = 1
        LEFT JOIN {{chain}}.signatures sig ON topic0 = sig.id AND sig.name = c.name AND sig.namespace = c.namespace
        WHERE l.tx_hash = {{tx hash}}
        and l.block_number = {{blocknumber}}
        order by index asc
    )
    
    , logs_ordered as (
        SELECT 
            l.decoded_table_name
            , l.function_event
            , get_href(get_chain_explorer_address('{{chain}}', l.contract_address), cast(l.contract_address as varchar)) as contract_address
            , null as "from"
            , l.signature
            , true as success
            , coalesce(trace_address, lag(trace_address, 1) IGNORE NULLS OVER (PARTITION BY 1 ORDER BY l.index asc)) as trace_address --|| 9999 can be added to place the event at the very end of the trace.
            , l.index as evt_index
        FROM logs_base l 
        LEFT JOIN (SELECT 
                    *
                    , row_number() over (partition by contract_address order by trace_address asc) as contract_call_count
                FROM calls_base
                WHERE function_type not in ('view','pure')
                and call_type not in ('staticcall', 'delegatecall')
            ) c
            ON c.contract_address = l.contract_address AND c.contract_call_count = l.event_log_count
        order by l.index asc, trace_address asc
    )

SELECT
*
FROM (
SELECT 
    array_join(repeat('&nbsp&nbsp', cast(cardinality(trace_address) as int)) , '') 
    || cast(cardinality(trace_address) as varchar) 
    || ' -> 🟢 '
    || call_type
        as tx_type
    , decoded_table_name
    , function_event
    , get_href(get_chain_explorer_address('{{chain}}', contract_address),cast(contract_address as varchar)) as contract_address
    , "from"
    , signature
    , success
    , trace_address
    , null as evt_index
FROM calls_base
UNION ALL 
SELECT
    array_join(repeat('&nbsp&nbsp', cast(cardinality(trace_address) as int)) , '') 
    || '&nbsp&nbsp-> 🟠 event'
    as tx_type
    , *
FROM logs_ordered
)
WHERE ('{{ignore unknown}}' = 'false' OR decoded_table_name not like '%unknown_%')
order by trace_address asc, evt_index asc nulls first

--, suggested table to use, could be much more built out since this is just a showcase
-- , case when tr.function_name LIKE '%transfer%' OR bytearray_substring(tr.input,1,4) IN (0xa9059cbb, 0x23b872dd, 0x36c78516) then 'erc20_{{chain}}.evt_Transfer'
--     when lower(tr.function_name) LIKE '%approve%' then 'erc20_{{chain}}.evt_Approval'
--     when lower(tr.function_name) LIKE '%swap%' AND tr.namespace IN ('oneinch','zeroex','cowprotocol','paraswap') then 'dex_aggregator.trades'
--     when lower(tr.function_name) LIKE '%swap%' AND tr.namespace NOT IN ('oneinch','zeroex','cowprotocol','paraswap') then 'dex.trades'
--     when lower(tr.function_name) LIKE '%flashloan%' AND tr.namespace LIKE '%aave%' then 'aave.flashloans' 
--     end as spellbook_table_name
-- , reduce(
--       cast(json_parse(json_query(s.abi,'lax $.inputs[*]' with array wrapper)) as array(row(name varchar, type varchar))),
--       '',
--       (acc, elem) -> acc || '<b>' || elem.name || '</b>::' || elem.type || ', ',
--       acc -> rtrim(acc, ', ')
--      ) as inputs
-- , reduce(
--       cast(json_parse(json_query(s.abi,'lax $.outputs[*]' with array wrapper)) as array(row(name varchar, type varchar))),
--       '',
--       (acc, elem) -> acc || '<b>' || elem.name || '</b>::' || elem.type || ', ',
--       acc -> rtrim(acc, ', ')
--      ) as outputs
