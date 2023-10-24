with deposit_data as (
    select 
        _token as token,
        count(*) as txs,
        sum(_amount) as deposits_amount
    from zksync_ethereum.ZkSync_call_depositERC20
    where call_success
    group by 1
),
token_data as (
    select 
        contract_address as token,
        decimals,
        symbol
    from 
        tokens.erc20
),
token_price as (
    select contract_address, price
    from 
        (select 
            contract_address, 
            price,
            ROW_NUMBER() OVER (PARTITION BY contract_address ORDER BY minute DESC) AS index
        from prices.usd
        where contract_address in (select token from deposit_data) 
        ) tmp
    where index = 1
)


select 
    t.symbol as symbol,
    d.txs as txs,
    d.deposits_amount / pow(10, t.decimals) as num_deposits,
    coalesce(d.deposits_amount / pow(10, t.decimals) * p.price, 0) as estimate_price_usd
from deposit_data d
left join token_data t on d.token = t.token
left join token_price p on d.token = p.contract_address 
order by 2 desc 