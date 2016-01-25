CREATE OR REPLACE FUNCTION tests.test_move()
 RETURNS TABLE(name character varying, result boolean)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY (SELECT 'test move 1'::varchar AS name, true AS result);
  RETURN QUERY (SELECT 'test move 2'::varchar AS name, false AS result);
END;
$function$
;