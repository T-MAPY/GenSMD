CREATE OR REPLACE FUNCTION m1.gen_load_data()
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
BEGIN
  PERFORM m1.gen_topo_unregister();
  
  TRUNCATE m1_data.elements_in CASCADE;
  
  INSERT INTO m1_data.elements_in (elm_id, elt_id, rotation, geom)
    SELECT elm_id, target_elt_id, target_rotation, target_geom FROM data.elements;

  PERFORM setval('m1_data.elements_in_elm_id_seq', (SELECT last_value + 1 FROM data.elements_elm_id_seq));
   
  PERFORM m1.gen_topo_update();
  RETURN true;
END;
$function$
;