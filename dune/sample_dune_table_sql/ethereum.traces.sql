-- Q1
select *
from ethereum.traces tr
where tx_hash = 0xe3eb29abc9c26e3b1baf55998054f322dc3f1723ea080656d59c01085e8202e0
AND block_number = 15216048

-- Q2 --> current
select *
from ethereum.traces tr
where tx_hash = 0xb45f940a8e32d1cc52921a20d3d18b30dd511241a82396e44076dcca3277bd1c
AND block_number = 15253444
