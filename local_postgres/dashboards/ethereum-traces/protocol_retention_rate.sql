with base as (
    SELECT
        distinct date_trunc('month', tx.block_time) as "month",
        tx."from" as "user"
    FROM
        "ethereum.transactions" tx
    WHERE
        tx."to" = '0x1f9840a85d5af5bf1d1762f925bdaddc4201f984'
        AND tx.success
        AND tx.block_time >= now() - interval '3' month
)
, user_cohort as (
    --get the cohort start month for a specific user address
    SELECT
        min("month") as cohort
        , "user"
    FROM base
    group by 2
 )
 ,cohort_size as (
   -- get the number of users of each start month
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
    ) t
)
, retention_base as (
    select rb0.cohort, total_size, array_agg(rentention) as rententions from (SELECT 
        a.cohort
        , a.months
        , a.active_addresses
        , total_size
        , cast(active_addresses as double precision)/cast(total_size as double precision) as rentention
    FROM active_by_cohort a 
    LEFT JOIN cohort_size c ON c.cohort = a.cohort
    GROUP BY a.cohort, a.months, a.active_addresses, total_size
    order by a.cohort, a.months) rb0 group by rb0.cohort, total_size
)
SELECT 
    substring(cast(cohort as varchar),1,10) as cohort
    , total_size
    , rententions[1] as month_1
    , rententions[2] as month_2
    , rententions[3] as month_3
FROM retention_base
order by cohort asc