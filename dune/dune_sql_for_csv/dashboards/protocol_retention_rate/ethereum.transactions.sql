SELECT
    distinct date_trunc('month', tx.block_time) as month,
    tx."from" as user
FROM
    ethereum.transactions tx
WHERE
    tx.to = 0x1f9840a85d5af5bf1d1762f925bdaddc4201f984
    AND tx.success
    AND tx.block_time >= now() - interval '3' month