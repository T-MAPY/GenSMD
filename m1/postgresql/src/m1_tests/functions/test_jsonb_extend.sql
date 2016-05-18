CREATE OR REPLACE FUNCTION m1_tests.test_jsonb_extend()
 RETURNS TABLE(name character varying, result boolean)
 LANGUAGE plpgsql
AS $function$
DECLARE
  data1 jsonb;
  data2 jsonb;
BEGIN
  data1 := '{"a": 1, "b": {"c": 1, "d": [1]}}'::jsonb;
  data2 := '{"a": 2, "b": {"c": 3}}'::jsonb;
  
  RETURN QUERY (
    SELECT 'm1_utils.jsonb_extend - all variants'::varchar AS name, 
    COALESCE((SELECT m1_utils.jsonb_extend(data1, data2)) = '{"a": 2, "b": {"c": 3, "d": [1]}}'::jsonb, false) AS result
  );

END;
$function$
;