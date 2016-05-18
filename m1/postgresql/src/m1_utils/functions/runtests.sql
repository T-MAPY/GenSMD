CREATE OR REPLACE FUNCTION m1_utils.runtests(filter character varying DEFAULT '^test_'::character varying, schemafilter character varying DEFAULT '^m1_tests$'::character varying)
 RETURNS TABLE(test character varying, name character varying, result boolean)
 LANGUAGE plpgsql
AS $function$
DECLARE
  r record;
  funcCall varchar;
BEGIN
  FOR r IN (
    SELECT p.proname, n.nspname
    FROM pg_proc p 
    LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
    WHERE 
      p.proname ~ filter 
      AND n.nspname ~ schemaFilter
      AND array_length(p.proargtypes, 1) = 0 
    ORDER BY p.proname
  ) LOOP
    funcCall := r.nspname || '.' || r.proname;
    funcCall := 'SELECT ''' || funcCall || '''::varchar AS test, * FROM ' || funcCall || '()';
    --RAISE NOTICE 'call: %', funcCall;
    RETURN QUERY EXECUTE funcCall;
  END LOOP;
END;
$function$
;