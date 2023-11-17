with 
    inputs_agg as (
        SELECT 
            distinct
            json_value(functions, 'name') as signature
            , json_value(functions, 'stateMutability') as function_type_raw
            , name
            , namespace
            , json_value(functions, 'inputs') as inputs
            , json_value(functions, 'outputs') as outputs
            , functions::text
        FROM (
            SELECT
                *
            FROM (
                SELECT 
                    name
                    , namespace
                    , abi
                    -- , *
                FROM "ethereum.contracts"
                WHERE address = '0x1f9840a85d5af5bf1d1762f925bdaddc4201f984'
                ) a, json_array_elements(abi) as abi_un(functions)
            ) b
        WHERE functions::text LIKE '%"type":"function"%'
    ), unnested_functions as (
        SELECT 
            inputs_agg.signature
            , inputs_agg.function_type_raw
            , inputs_agg.name 
            , inputs_agg.namespace
            , concat(json_value(i, 'name'), '::', json_value(i, 'type')) as inputs
            , concat(json_value(o, 'name'), '::', json_value(o, 'type')) as outputs
        FROM inputs_agg, json_array_elements(inputs::json) as i(input) , json_array_elements(outputs::json) as o(output)
    )
    SELECT
    signature
    , function_type_raw
    -- , name 
    -- , namespace
    , concat(namespace, '_', 'ethereum', '.', name, '_call_', signature) as table_name
    , array_agg(distinct inputs) as _inputs
    , array_agg(distinct outputs) as _outputs
FROM unnested_functions
GROUP BY 1,2,3
ORDER BY function_type_raw asc, cardinality(array_agg(distinct inputs)) DESC
    