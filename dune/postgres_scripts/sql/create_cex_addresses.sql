DROP TABLE if exists "cex.addresses" CASCADE;

CREATE TABLE "cex.addresses"(
    blockchain TEXT,
    address TEXT,
    cex_name TEXT,
    distinct_name TEXT,
    added_by TEXT,
    added_date date
);