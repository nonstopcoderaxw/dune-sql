with
  pted_cex_addresses as (
    select
      *, row_number() over (partition by cex_name) as partition_number
    from
      cex.addresses
    where
      cex_name in ('Korbit', 'Upbit', 'Bithumb', 'Coinone', 'GOPAX')
  )
  select * from pted_cex_addresses where partition_number <= 10