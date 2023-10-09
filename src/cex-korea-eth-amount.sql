-- code reference: 
with cex_kr as (
    select * from cex.addresses
    where cex_name in ('Korbit', 'Upbit', 'Bithumb', 'Coinone', 'GOPAX')
)
,amount_series as (
SELECT 
    date_trunc('week', block_time) as dt,
    cex_name, 
    sum(amount) as amount
FROM (
    -- outbound transfers
    SELECT 
        cex.cex_name, 
        block_time,
        -1*cast(value as int256)/1e18 AS amount
    FROM ethereum.traces tr
    LEFT JOIN cex_kr AS cex ON cex.address = tr."from"
    WHERE tr."from" = cex.address
    AND success
    AND (LOWER(call_type) NOT IN ('delegatecall', 'callcode', 'staticcall') or call_type is null)
    AND 
        CASE WHEN block_number < 4370000  THEN True
        WHEN block_number >= 4370000 THEN tx_success
    END 

    UNION ALL
    
    -- inbound transfers
    SELECT 
        cex.cex_name, 
        block_time,
        value/1e18 AS amount
    FROM ethereum.traces tr
    LEFT JOIN cex_kr AS cex ON cex.address = tr."to"
    WHERE tr."to" = cex.address
    AND success
    AND (LOWER(call_type) NOT IN ('delegatecall', 'callcode', 'staticcall') or call_type is null)
    AND 
        CASE WHEN block_number < 4370000  THEN True
        WHEN block_number >= 4370000 THEN tx_success
    END 

    UNION ALL
    
    -- gas costs
    SELECT 
        cex.cex_name, 
        block_time,
        cast(-1 as int256)*cast(gas_price as int256)*cast(gas_used as int256)/1e18 AS amount
    FROM ethereum.transactions tr
    LEFT JOIN cex_kr AS cex ON tr."from" = cex.address
    WHERE tr."from" = cex.address
) t
GROUP BY 1, 2
),
date_period as (
    select *
    from (select distinct dt from amount_series)
    cross join (select distinct cex_name from cex_kr)
)


select 
    dp.dt,
    dp.cex_name,
    coalesce(amount, 0) as amount,
    sum(coalesce(amount, 0)) over(partition by dp.cex_name order by dp.dt asc) as amount_total
from date_period dp
left join amount_series a on dp.dt = a.dt and dp.cex_name = a.cex_name

-- select * from date_period