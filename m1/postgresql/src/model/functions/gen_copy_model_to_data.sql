CREATE OR REPLACE FUNCTION model.gen_copy_model_to_data()
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
BEGIN

  TRUNCATE data.elements_in CASCADE;
  TRUNCATE data.element_footprints CASCADE;
  TRUNCATE data.elements_proc CASCADE;
  
  TRUNCATE data.element_types_relations CASCADE;
  TRUNCATE data.element_types CASCADE;
  
  INSERT INTO data.element_types (elt_id, geom_type, priority, footprint, topology)
  SELECT 
    id, 
    json_extract_path_text(json_object('{"point", 1, "line", 2, "polygon", 3}'), geomtype)::smallint,
    priority,
    COALESCE(footprint, '{}'::jsonb),
    topology
  FROM model.vw_element_types_load;

  INSERT INTO data.element_types_relations (elt_id_from, elt_id_to, conflict, clearence, footprint_from, footprint_to)
  SELECT 
    id_from, 
    id_to, 
    CASE merged ->> 'conflict' WHEN 'true' THEN true ELSE false END,
    COALESCE(merged ->> 'clearence', '0')::float,
    merged -> 'footprint_from',
    merged -> 'footprint_to'
  FROM model.element_types_relations_load;

  RETURN true;
  
END;
$function$
;