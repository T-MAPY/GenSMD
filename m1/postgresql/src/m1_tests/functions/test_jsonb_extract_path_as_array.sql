CREATE OR REPLACE FUNCTION m1_tests.test_jsonb_extract_path_as_array()
 RETURNS TABLE(name character varying, result boolean)
 LANGUAGE plpgsql
AS $function$
DECLARE
  data jsonb;
BEGIN
  data := '{"a":[{"c":1},{"d":2}], "b":{"c":1}}'::jsonb;
  
  RETURN QUERY (
    SELECT 'm1.jsonb_extract_path_as_array - simple'::varchar AS name, 
    COALESCE((SELECT m1_utils.jsonb_extract_path_as_array(data, 'b')) = array['{"c": 1}'::jsonb], false) AS result
  );

  RETURN QUERY (
    SELECT 'm1.jsonb_extract_path_as_array - array'::varchar AS name, 
    COALESCE((SELECT m1_utils.jsonb_extract_path_as_array(data, 'a')) = array['{"c": 1}'::jsonb, '{"d": 2}'::jsonb], false) AS result
  );
END;
$function$
;