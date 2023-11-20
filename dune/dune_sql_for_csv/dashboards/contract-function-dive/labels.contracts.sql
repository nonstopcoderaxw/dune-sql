select * 
from labels.contracts 
where blockchain = 'ethereum' 
and address = 0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48 
order by created_at desc limit 1