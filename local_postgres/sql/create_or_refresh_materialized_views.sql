-- evms.contracts.last_submitted
create materialized view IF NOT exists "evms.contracts.last_submitted" as
SELECT
    *,
    row_number() over (
        partition by blockchain,
        address
        order by
            created_at desc
    ) as last_submitted
FROM
    "evms.contracts";

REFRESH MATERIALIZED view "evms.contracts.last_submitted";