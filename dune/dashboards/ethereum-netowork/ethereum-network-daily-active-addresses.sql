WITH sending_users AS (
SELECT day, COUNT(*) AS send_user
FROM (
    SELECT
    DATE_TRUNC('day',block_time) AS day,"from"
    FROM ethereum.transactions
    WHERE
    success AND block_time >= (DATE_TRUNC('day',NOW()) - interval '{{Trailing Number of Days}}' day)
    AND 1=
        (CASE WHEN '{{Show Today - if available}}' = 'Yes' THEN 1 
            WHEN '{{Show Today - if available}}' = 'No' AND block_time < (DATE_TRUNC('day',NOW())) THEN 1
            ELSE 0
        END)
    GROUP BY 1,2
    ) s
GROUP BY 1
)

, receiving_users AS (
SELECT day, COUNT(*) AS receive_user
FROM (
    SELECT
    DATE_TRUNC('day',block_time) AS day,to
    FROM ethereum.transactions
    WHERE
    success AND block_time >= (DATE_TRUNC('day',NOW()) - interval '{{Trailing Number of Days}}' day)
    AND 1=
        (CASE WHEN '{{Show Today - if available}}' = 'Yes' THEN 1 
            WHEN '{{Show Today - if available}}' = 'No' AND block_time < (DATE_TRUNC('day',NOW())) THEN 1
            ELSE 0
        END)
    GROUP BY 1,2
    ) s
GROUP BY 1
)

, total_addrs AS (
SELECT
day,COUNT(*) AS total_users
FROM 
    (
    SELECT day, addr
    FROM (
        SELECT
        DATE_TRUNC('day',block_time) AS day
        ,"from" AS addr
        FROM ethereum.transactions
        WHERE success AND block_time >= (DATE_TRUNC('day',NOW()) - interval '{{Trailing Number of Days}}' day)
        AND 1=
            (CASE WHEN '{{Show Today - if available}}' = 'Yes' THEN 1 
                WHEN '{{Show Today - if available}}' = 'No' AND block_time < (DATE_TRUNC('day',NOW())) THEN 1
                ELSE 0
            END)
        GROUP BY 1,2
        
        UNION ALL
        
        SELECT
        DATE_TRUNC('day',block_time) AS day
        , to AS addr
        FROM ethereum.transactions
        WHERE success AND block_time >= (DATE_TRUNC('day',NOW()) - interval '{{Trailing Number of Days}}' day)
        AND 1=
            (CASE WHEN '{{Show Today - if available}}' = 'Yes' THEN 1 
                WHEN '{{Show Today - if available}}' = 'No' AND block_time < (DATE_TRUNC('day',NOW())) THEN 1
                ELSE 0
            END)
        GROUP BY 1,2
        ) a
    GROUP BY 1,2
    ) b
GROUP BY 1
)

-- , user_gran AS (
-- SELECT dt,
-- dau,
-- CASE WHEN dt >= (SELECT mindt FROM min_date) + interval '6 days' THEN wau ELSE NULL END AS wau,
-- CASE WHEN dt >= (SELECT mindt FROM min_date) + interval '6 days' THEN weekly_days_active ELSE NULL END AS weekly_days_active,
-- CASE WHEN dt >= (SELECT mindt FROM min_date) + interval '29 days' THEN mau ELSE NULL END AS mau,
-- CASE WHEN dt >= (SELECT mindt FROM min_date) + interval '29 days' THEN monthly_days_active ELSE NULL END AS monthly_days_active,

-- DENSE_RANK() OVER (PARTITION BY DATE_TRUNC('week',dt) ORDER BY dt DESC) AS week_rank,
-- DENSE_RANK() OVER (PARTITION BY DATE_TRUNC('month',dt) ORDER BY dt DESC) AS month_rank,

-- AVG(dau) OVER (ORDER BY dt ASC ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS dau_7dma,
-- AVG(dau) OVER (ORDER BY dt ASC ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS dau_30dma

-- FROM (
-- SELECT t.dt
--         ,(SELECT COUNT(DISTINCT "from")
--         FROM dt_froms m
--         WHERE m.dt = t.dt
--         ) AS dau
        
--         ,(SELECT COUNT(DISTINCT "from")
--         FROM dt_froms w
--         WHERE w.dt BETWEEN /*DATE_TRUNC('week',t.dt)*/ t.dt - interval '6 days' AND t.dt
--         ) AS wau
        
--         ,(SELECT COUNT("from")
--         FROM dt_froms w
--         WHERE w.dt BETWEEN /*DATE_TRUNC('week',t.dt)*/ t.dt - interval '6 days' AND t.dt
--         ) AS weekly_days_active
        
--         ,(SELECT COUNT(DISTINCT "from")
--         FROM dt_froms m
--         WHERE m.dt BETWEEN /*DATE_TRUNC('month',t.dt)*/ t.dt - interval '29 days' AND t.dt
--         ) AS mau
        
--         ,(SELECT COUNT("from")
--         FROM dt_froms m
--         WHERE m.dt BETWEEN /*DATE_TRUNC('month',t.dt)*/ t.dt - interval '29 days' AND t.dt
--         ) AS monthly_days_active
        
--     FROM (SELECT dt FROM dt_froms GROUP BY 1) t
--     ) a
-- )
SELECT
u.day AS "Day"
--,u.trail_day
,u.send_user AS "# Sending Addresses (S)"
,r.receive_user AS "# Receiving Addresses (R)"
,tt.total_users AS "# Total Addresses"
,ROUND(cast(u.send_user as double)/cast(r.receive_user as double),2) AS "S/R Ratio"

,1 AS "Baseline"
FROM sending_users u
INNER JOIN receiving_users r
    ON r.day = u.day
INNER JOIN total_addrs tt
    ON tt.day = u.day

ORDER BY u.day DESC