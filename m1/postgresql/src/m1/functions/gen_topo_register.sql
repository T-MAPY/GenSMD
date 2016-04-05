CREATE OR REPLACE FUNCTION m1.gen_topo_register()
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF (topology.TopologySummary('topo_data') !~ 'unregistered') THEN
    PERFORM topology.DropTopology('topo_data');
  END IF;
  
  DROP TABLE IF EXISTS work.elements_topo;
  CREATE TABLE work.elements_topo AS 
    SELECT elm_id 
    FROM data.elements e 
    INNER JOIN data.element_types et ON e.elt_id = et.elt_id 
    WHERE et.topology_participant; 

  ALTER TABLE ONLY work.elements_topo ADD CONSTRAINT elements_pkey PRIMARY KEY (elm_id);
    
  PERFORM topology.CreateTopology('topo_data');
  PERFORM topology.AddTopoGeometryColumn ('topo_data', 'work', 'elements_topo', 'topo_pt', 'POINT');
  PERFORM topology.AddTopoGeometryColumn ('topo_data', 'work', 'elements_topo', 'topo_ln', 'LINE');
  PERFORM topology.AddTopoGeometryColumn ('topo_data', 'work', 'elements_topo', 'topo_pl', 'POLYGON');

  UPDATE work.elements_topo t 
  SET topo_pl = topology.toTopoGeom(ST_SnapToGrid(e.geom, 0.05), 'topo_data', 3, 0.1) 
  FROM data.elements e 
  WHERE t.elm_id = e.elm_id AND GeometryType(e.geom) = 'POLYGON';
 
  UPDATE work.elements_topo t 
  SET topo_ln = topology.toTopoGeom(ST_SnapToGrid(e.geom, 0.05), 'topo_data', 2, 0.1) 
  FROM data.elements e 
  WHERE t.elm_id = e.elm_id AND GeometryType(e.geom) = 'LINESTRING';

  UPDATE work.elements_topo t 
  SET topo_pt = topology.toTopoGeom(ST_SnapToGrid(e.geom, 0.05), 'topo_data', 1, 0.1) 
  FROM data.elements e 
  WHERE t.elm_id = e.elm_id AND GeometryType(e.geom) = 'POINT';

  RETURN true;
END;
$function$
;