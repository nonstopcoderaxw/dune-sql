-- source: https://dune.com/queries/1537309/2577373
with 
    inputs_agg as (
        SELECT 
            distinct
            json_value(functions, 'strict $.name') as signature
            , json_value(functions, 'strict $.stateMutability') as function_type_raw
            , name
            , namespace
            , cast(json_parse(json_query(functions,'lax $.inputs[*]' with array wrapper)) as array(row(name varchar, type varchar))) as inputs
            , cast(json_parse(json_query(functions,'lax $.outputs[*]' with array wrapper)) as array(row(name varchar, type varchar))) as outputs
            , functions
        FROM (
            SELECT
                *
            FROM (
                SELECT 
                    name
                    , namespace
                    , abi
                    -- , *
                FROM ethereum.contracts
                WHERE address = 0x1f9840a85d5af5bf1d1762f925bdaddc4201f984 and name = 'UNI' and namespace = 'uniswap'
                ) a, unnest(abi) as abi_un(functions)
            ) b
        WHERE functions LIKE '%"type":"function"%'
    ),
    unnested_functions as (
        SELECT 
            inputs_agg.signature
            , inputs_agg.function_type_raw
            , inputs_agg.name 
            , inputs_agg.namespace
            , concat(i.names, '::', i.types) as inputs
            , concat(o.names, '::', o.types) as outputs
        FROM inputs_agg, unnest(inputs) as i(names, types), unnest(outputs) as o(names, types)
    )

SELECT
    signature
    , function_type_raw
    -- , name 
    -- , namespace
    , concat(namespace, '_', 'ethereum', '.', name, '_call_', signature) as table_name
    , array_agg(distinct inputs) inputs
    , array_agg(distinct outputs) outputs
FROM unnested_functions
GROUP BY 1,2,3
ORDER BY function_type_raw ASC, cardinality(inputs) DESC