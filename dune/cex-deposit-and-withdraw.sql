-- https://dune.com/queries/3074872/5123537
-- weekly deposit and withdraw
with cex_kr as (
    select * from cex.addresses
    where cex_name in ('Korbit', 'Upbit', 'Bithumb', 'Coinone', 'GOPAX')
)
,cex_kr_txs as (
    select 
        *, 
        'cex->user' as tp
    from ethereum.transactions
    where "from" in (select address from cex_kr)
    union all 
    select 
        *,
        'user->cex' as tp
    from ethereum.transactions
    where "to" in (select address from cex_kr)
),
stats as (
select 
    date_trunc('week',block_time) as dt,
    count(*) as txs,
    sum(case when tp='cex->user' then 1 else 0 end) as cex_to_user_txs,
    sum(case when tp='user->cex' then 1 else 0 end) as user_to_cex_txs,
    count(distinct "from") as unique_deposit,
    count(distinct "to") as unique_withdraw
from cex_kr_txs
group by 1
)

select 
    *,
    -- below is the calculate the running total on tx by week
    sum(txs) over(order by dt asc) as total_txs
from stats