CREATE OR REPLACE FUNCTION m1.gen_topo_register()
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF (m1.gen_topo_is_registered()) THEN
    RAISE NOTICE 'TOPO is already registered';
    RETURN false;
  END IF;
  
  RAISE NOTICE 'TOPO Create topology';
  PERFORM topology.CreateTopology('topo_data');
  PERFORM topology.AddTopoGeometryColumn ('topo_data', 'data', 'elements_in', 'topo_pt', 'POINT');
  PERFORM topology.AddTopoGeometryColumn ('topo_data', 'data', 'elements_in', 'topo_ln', 'LINE');
  PERFORM topology.AddTopoGeometryColumn ('topo_data', 'data', 'elements_in', 'topo_pl', 'POLYGON');
  
  RETURN true;
END;
$function$
;