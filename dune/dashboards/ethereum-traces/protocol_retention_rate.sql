-- source: https://dune.com/queries/2052477/3395440
-- source: https://dune.com/queries/2052477/3395440
-- This query used incompatible data types from Dune SQL alpha and may need to be updated.
-- More details can be found on https://dune.com/docs/query/dunesql-changes/
with
    base as (
        SELECT
            distinct
            date_trunc('month', tx.block_time) as month
            , tx."from" as user
        FROM ethereum.transaction tx
        -- LEFT JOIN decoding.evm_signatures sig_fx ON substring(tr.input,1,10) = sig_fx.id 
        --     AND sig_fx.type = 'function_call'
        --     AND lower(c.name) = lower(concat(sig_fx.namespace, ': ', sig_fx.name))
        WHERE tx.to = {{contract}}
        AND tx.success
        AND tx.block_time >= now() - interval '{{months ago}}' month
    )

, user_cohort as (
    --get the cohort start month for a specific user address
    SELECT
        min(month) as cohort
        , user
    FROM base
    group by 2
 ) 
 
, cohort_size as (
    SELECT 
        cohort
        , count(*) as total_size
    FROM user_cohort
    group by 1
)

, active_by_cohort as (
    SELECT
        cohort
        , month
        , row_number() OVER (partition by cohort order by month asc) as months
        , active_addresses
    FROM (
        SELECT 
            u.cohort
            , b.month
            , count(*) as active_addresses
        FROM base b 
        LEFT JOIN user_cohort u ON u.user = b.user
        group by 1,2
    ) 
)

, retention_base as (
    SELECT 
        a.cohort
        , total_size
        , map_agg(months, cast(active_addresses as double)/cast(total_size as double)) as retention_key
    FROM active_by_cohort a 
    LEFT JOIN cohort_size c ON c.cohort = a.cohort
    GROUP BY 1,2
) 

SELECT 
    substring(cast(cohort as varchar),1,10) as cohort
    , total_size
    , try(retention_key[2]) as month_1
    , try(retention_key[3]) as month_2
    , try(retention_key[4]) as month_3
    , try(retention_key[5]) as month_4
    , try(retention_key[6]) as month_5
    , try(retention_key[7]) as month_6
    , try(retention_key[8]) as month_7
    , try(retention_key[9]) as month_8
    , try(retention_key[10]) as month_9
    , try(retention_key[11]) as month_10
    , try(retention_key[12]) as month_11
    , try(retention_key[13]) as month_12
FROM retention_base
order by cohort asc