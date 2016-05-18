CREATE OR REPLACE FUNCTION m1.gen_topo_unregister()
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
BEGIN
  RAISE NOTICE 'TOPO Unregister';
  IF (m1.gen_topo_is_registered()) THEN
    PERFORM topology.DropTopology('m1_topo_data');
  END IF;
  ALTER TABLE m1_data.elements_in 
    DROP COLUMN IF EXISTS topo_pt,
    DROP COLUMN IF EXISTS topo_ln,
    DROP COLUMN IF EXISTS topo_pl;
    
  RETURN true;
END;
$function$
;