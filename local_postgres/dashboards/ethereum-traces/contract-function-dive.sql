-- contract address: 0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48 - usdc
with
    base as (

            SELECT 
                SUBSTR(tx.input,1,10) as funcsig
                , count(*) as times_called_all
                , min(tx.tx_hash) as hash_example
            FROM "ethereum.traces" tx --make this traces in duneSQL
            WHERE tx.to = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48'
                AND tx.success
                AND tx.input != '0x' --don't want transfers
            GROUP BY 1
    )
SELECT 
    distinct
    base.funcsig as raw_funcsig
   , coalesce(split_part(sig_fx.signature,'(',1), 'unknown') as decoded_function
    , json_value(sig_fx.abi,'stateMutability') as function_type_raw
    , times_called_all
    , case when json_value(sig_fx.abi,'stateMutability') IN ('pure', 'view') then 2 else 1 end as ordering
FROM base
LEFT JOIN "labels.contracts" c ON c.blockchain = 'ethereum' AND c.address = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48'
LEFT JOIN "ethereum.signatures" sig_fx ON base.funcsig = sig_fx.id 
    AND sig_fx.type = 'function_call' 
    AND lower(c.name) = lower(concat(sig_fx.namespace, ': ', sig_fx.name))
ORDER BY ordering asc, times_called_all desc

