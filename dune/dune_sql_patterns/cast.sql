select -1*cast(value as int256)/1e18 AS amount, block_hash, value
from ethereum.traces tr
limit 1
