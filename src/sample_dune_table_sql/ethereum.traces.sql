select *, row_number() over (partition by tr.address) as partition_number
from ethereum.traces tr
where (LOWER(call_type) NOT IN ('delegatecall', 'callcode', 'staticcall') or call_type is null)
AND block_number < 18389755
limit 50
