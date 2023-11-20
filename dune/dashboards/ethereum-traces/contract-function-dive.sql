-- This query used incompatible data types from Dune SQL alpha and may need to be updated.
-- More details can be found on https://dune.com/docs/query/dunesql-changes/
with
    base as (
        -- SELECT
        --     funcsig
        --     , times_called_all
        --     , event_topic
        --     , hash_example
        -- FROM (
            SELECT 
                bytearray_substring(tx.input,1,4) as funcsig
                , count(*) as times_called_all
                -- , array_agg(distinct lg.topic1) as event_topics
                , min(tx.tx_hash) as hash_example
            FROM {{chain}}.traces tx --make this traces in duneSQL
            -- LEFT JOIN {{chain}}.logs lg ON lg.tx_hash = tx.hash
            --     AND lg.contract_address = lower('{{contract}}')
            WHERE tx.to = {{contract}}
                AND tx.success
                AND tx.input != 0x --don't want transfers
            GROUP BY 1
    )

SELECT 
    distinct
    base.funcsig as raw_funcsig
   , concat('<a href="', get_chain_explorer.explorer, '/tx/', cast(hash_example as varchar)
        , '" target = "blank">'
        , coalesce(split_part(sig_fx.signature,'(',1), 'unknown')
        , '</a>')
    as decoded_function
    , json_value(sig_fx.abi,'strict $.stateMutability') as function_type_raw
    , times_called_all
    , case when json_value(sig_fx.abi,'strict $.stateMutability') IN ('pure', 'view') then 2 else 1 end as ordering
    -- , array_agg(
    --     coalesce(split_part(sig_evt.signature,'(',1), base.event_topic, null)
    --     ) FILTER (WHERE base.event_topic IS NOT NULL) as events_emitted
FROM base
LEFT JOIN labels.contracts c ON c.blockchain = '{{chain}}' AND c.address = {{contract}}
LEFT JOIN {{chain}}.signatures sig_fx ON base.funcsig = sig_fx.id 
    AND sig_fx.type = 'function_call' 
    AND lower(c.name) = lower(concat(sig_fx.namespace, ': ', sig_fx.name))
-- LEFT JOIN {{chain}}.signatures sig_evt ON base.event_topic = sig_evt.id AND sig_evt.type = 'event'
LEFT JOIN query_1747157 get_chain_explorer ON get_chain_explorer.chain = '{{chain}}'
-- GROUP BY 1,2,3,4
ORDER BY ordering asc, times_called_all desc