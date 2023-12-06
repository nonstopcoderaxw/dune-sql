-- This query used incompatible data types from Dune SQL alpha and may need to be updated.
-- More details can be found on https://dune.com/docs/query/dunesql-changes/
with 
    inputs_agg as (
        SELECT 
            distinct
            json_value(functions, 'strict $.name') as signature
            , name
            , namespace
            , cast(json_parse(json_query(functions,'lax $.inputs[*]' with array wrapper)) as array(row(name varchar, type varchar, indexed boolean))) as inputs
            , functions
        FROM (
            SELECT
                *
            FROM (
                SELECT 
                    name
                    , namespace
                    , abi
                FROM {{chain}}.contracts
                WHERE address = {{contract}}
                ) a, unnest(abi) as abi_un(functions)
            ) b
        WHERE functions LIKE '%"type":"event"%'
    ), 
    
    unnested_functions as (
        SELECT 
            inputs_agg.signature
            , inputs_agg.name 
            , inputs_agg.namespace
            , concat(case when i.indexed then '(index) ' else '' end, i.names, '::', i.types) as inputs
        FROM inputs_agg, unnest(inputs) as i(names, types, indexed)
    )

SELECT
    signature
    -- , name 
    -- , namespace
    , concat(namespace, '_', '{{chain}}', '.', name, '_evt_', signature) as table_name
    , array_agg(distinct inputs) inputs
FROM unnested_functions
GROUP BY 1,2
ORDER BY cardinality(inputs) DESC