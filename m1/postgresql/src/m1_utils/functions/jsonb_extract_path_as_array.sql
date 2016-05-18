CREATE OR REPLACE FUNCTION m1_utils.jsonb_extract_path_as_array(from_json jsonb, VARIADIC path_elems text[])
 RETURNS jsonb[]
 LANGUAGE plpgsql
AS $function$
DECLARE 
  jsn jsonb;
  ajsn jsonb[];
BEGIN
  jsn := jsonb_extract_path(from_json, VARIADIC path_elems);
  if (jsonb_typeof(jsn) = 'array') THEN
    SELECT INTO ajsn array_agg(j) FROM jsonb_array_elements(jsn) j;
  ELSE 
    ajsn := array[jsn];
  END IF;
  RETURN ajsn;
END;
$function$
;