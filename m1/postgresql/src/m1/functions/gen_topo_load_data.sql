CREATE OR REPLACE FUNCTION m1.gen_topo_load_data()
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
BEGIN
  RAISE NOTICE 'TOPO Update topology for POLYGON';
  UPDATE m1_data.elements_in t 
  SET topo_pl = topology.toTopoGeom(ST_SnapToGrid(e.geom, 0.05), 'm1_topo_data', 3, 0.1) 
  FROM m1_data.elements_in e 
  INNER JOIN m1_data.element_types et ON e.elt_id = et.elt_id 
  WHERE t.elm_id = e.elm_id AND et.topology AND GeometryType(e.geom) = 'POLYGON';
 
  RAISE NOTICE 'TOPO Update topology for LINE';
  UPDATE m1_data.elements_in t 
  SET topo_ln = topology.toTopoGeom(ST_SnapToGrid(e.geom, 0.05), 'm1_topo_data', 2, 0.1) 
  FROM m1_data.elements_in e 
  INNER JOIN m1_data.element_types et ON e.elt_id = et.elt_id 
  WHERE t.elm_id = e.elm_id AND et.topology AND GeometryType(e.geom) = 'LINESTRING';

  RAISE NOTICE 'TOPO Update topology for POINT';
  UPDATE m1_data.elements_in t 
  SET topo_pt = topology.toTopoGeom(ST_SnapToGrid(e.geom, 0.05), 'm1_topo_data', 1, 0.1) 
  FROM m1_data.elements_in e 
  INNER JOIN m1_data.element_types et ON e.elt_id = et.elt_id 
  WHERE t.elm_id = e.elm_id AND et.topology AND GeometryType(e.geom) = 'POINT';

  RAISE NOTICE 'TOPO load data INTO elements_gen_src';
  
  TRUNCATE m1_data.element_footprints;
  TRUNCATE m1_data.elements_proc;
  ALTER SEQUENCE m1_data.elements_proc_elm_proc_id_seq RESTART WITH 1;
  ALTER SEQUENCE m1_data.element_footprints_foo_id_seq RESTART WITH 1;
  
  INSERT INTO m1_data.elements_proc (elm_id, geom)
    SELECT e.elm_id, e.geom
    FROM m1_data.elements_in e 
    INNER JOIN m1_data.element_types et ON e.elt_id = et.elt_id 
    WHERE NOT et.topology; 
    
  INSERT INTO m1_data.elements_proc (edge_id, geom)
    SELECT e.edge_id, e.geom
    FROM m1_topo_data.edge_data e;

  UPDATE m1_data.elements_proc ep 
    SET weight = (
      SELECT max(weight) 
      FROM m1.gen_element_proc_get_info(ep.elm_proc_id) p 
      INNER JOIN m1_data.element_types et ON (p.elt_id = et.elt_id)
    );

  RETURN true;
END;
$function$
;