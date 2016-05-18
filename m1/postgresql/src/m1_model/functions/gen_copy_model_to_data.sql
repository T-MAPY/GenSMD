CREATE OR REPLACE FUNCTION m1_model.gen_copy_model_to_data()
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
BEGIN

  TRUNCATE m1_data.elements_in CASCADE;
  TRUNCATE m1_data.element_footprints CASCADE;
  TRUNCATE m1_data.elements_proc CASCADE;
  
  TRUNCATE m1_data.element_types_relations CASCADE;
  TRUNCATE m1_data.element_types CASCADE;
  
  INSERT INTO m1_data.element_types (elt_id, geom_type, priority, footprint, topology)
  SELECT 
    id, 
    json_extract_path_text(json_object('{"point", 1, "line", 2, "polygon", 3}'), geomtype)::smallint,
    priority,
    COALESCE(footprint, '{}'::jsonb),
    topology
  FROM m1_model.vw_element_types_load;

  INSERT INTO m1_data.element_types_relations (elt_id_from, elt_id_to, conflict, clearance, footprint_from, footprint_to)
  SELECT 
    id_from, 
    id_to, 
    CASE merged ->> 'conflict' WHEN 'true' THEN true ELSE false END,
    COALESCE(merged ->> 'clearance', '0')::float,
    merged -> 'footprint_from',
    merged -> 'footprint_to'
  FROM m1_model.element_types_relations_load
  WHERE merged ->> 'conflict' = 'true';

  RETURN true;
  
END;
$function$
;