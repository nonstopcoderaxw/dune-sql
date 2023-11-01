----- dune sql below -----
with last24_deposits as (
select 
count(distinct "from") as unique_addresses
,count(*) as txs
,sum(value)/1e18 as eth_amount
,sum(value)/1e18/count(*) as avg_eth_per_tx
from ethereum.transactions 
where to = 0xabea9132b05a70803a4e85094fd0e1800777fbef
and success 
and block_time > now() - interval '24' hour)

select * from last24_deposits




--------------------------------------------------------------------------------
------------------ sample postgre sql below ------------------------------------
select 
count(distinct "from") as unique_addresses
,count(*) as txs
,sum(value)/1e18 as eth_amount
,sum(value)/1e18/count(*) as avg_eth_per_tx
from "ethereum.transactions" 
where "to" = '0x6b75d8af000000e20b7a7ddf000ba900b4009a80'
and success 
and block_time > now() - interval '24' hour)
select * from last24_deposits

