DROP FUNCTION IF EXISTS json_value(json,text);


CREATE OR REPLACE FUNCTION public.json_value(j json, _key text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
        BEGIN
                RETURN j ->> _key;
        END;
$function$
;