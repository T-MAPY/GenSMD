CREATE OR REPLACE FUNCTION m1.gen_topo_unregister()
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
BEGIN
  RAISE NOTICE 'TOPO Unregister';
  IF (m1.gen_topo_is_registered()) THEN
    PERFORM topology.DropTopology('topo_data');
  END IF;
  RETURN true;
END;
$function$
;