CREATE OR REPLACE FUNCTION public.json_value(str json, _key text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
        BEGIN
                RETURN str -> _key;
        END;
$function$
;
