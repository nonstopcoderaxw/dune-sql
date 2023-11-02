select
	*,
	row_number() over (
		partition by blockchain,
		address
		order by
			created_at desc
	) as last_submitted
from
	evms.contracts
where created_at > now() - interval '2' day
and blockchain in ('ethereum', 'base', 'bnb', 'polygon')
