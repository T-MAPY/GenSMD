CREATE OR REPLACE FUNCTION m1.gen_topo_load_data()
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
BEGIN
  RAISE NOTICE 'TOPO Update topology for POLYGON';
  UPDATE data.elements_in t 
  SET topo_pl = topology.toTopoGeom(ST_SnapToGrid(e.geom, 0.05), 'topo_data', 3, 0.1) 
  FROM data.elements_in e 
  INNER JOIN data.element_types et ON e.elt_id = et.elt_id 
  WHERE t.elm_id = e.elm_id AND et.topology_participant AND GeometryType(e.geom) = 'POLYGON';
 
  RAISE NOTICE 'TOPO Update topology for LINE';
  UPDATE data.elements_in t 
  SET topo_ln = topology.toTopoGeom(ST_SnapToGrid(e.geom, 0.05), 'topo_data', 2, 0.1) 
  FROM data.elements_in e 
  INNER JOIN data.element_types et ON e.elt_id = et.elt_id 
  WHERE t.elm_id = e.elm_id AND et.topology_participant AND GeometryType(e.geom) = 'LINESTRING';

  RAISE NOTICE 'TOPO Update topology for POINT';
  UPDATE data.elements_in t 
  SET topo_pt = topology.toTopoGeom(ST_SnapToGrid(e.geom, 0.05), 'topo_data', 1, 0.1) 
  FROM data.elements_in e 
  INNER JOIN data.element_types et ON e.elt_id = et.elt_id 
  WHERE t.elm_id = e.elm_id AND et.topology_participant AND GeometryType(e.geom) = 'POINT';

  RAISE NOTICE 'TOPO load data INTO elements_gen_src';
  
  TRUNCATE data.elements_proc;
  INSERT INTO data.elements_proc (elm_id, geom)
    SELECT e.elm_id, e.geom
    FROM data.elements_in e 
    INNER JOIN data.element_types et ON e.elt_id = et.elt_id 
    WHERE NOT et.topology_participant; 
    
  INSERT INTO data.elements_proc (edge_id, geom)
    SELECT e.edge_id, e.geom
    FROM topo_data.edge_data e; 

  RETURN true;
END;
$function$
;